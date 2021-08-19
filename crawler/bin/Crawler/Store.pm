####################################################################################################
# Fichero: (Crawler::Store.pm) $Id: Store.pm,v 1.5 2004/10/04 10:38:28 fml Exp $
# Fecha: 15/08/2001
# Revision: Ver $VERSION
# DescripcióClase Crawler::Store
# Set Tab=3
#####################################################################################################
use Crawler;
package Crawler::Store;
@ISA=qw(Crawler);
$VERSION='1.00';
use strict;
use RRDs;
use libSQL;
use Digest::MD5 qw(md5_hex);
use Encode qw(encode_utf8);
use Metrics::Types qw(%PERIOD %CREATE %GRAPH);
use Time::Local;
use Data::Dumper;
use JSON;
use File::Copy;
use ATypes;
use ONMConfig;

#----------------------------------------------------------------------------
my $DIR_COUNTER_DATA='/opt/data/mdata/counter';

#----------------------------------------------------------------------------
my $ETXT='KEY-ERROR';

my %DB = (
        DRIVERNAME => "mysql",
        SERVER => "localhost",
        PORT => 3306,
        DATABASE => "onm",
        USER => "root",
        PASSWORD => "YamIhere",
        TABLE => 'devices',
);
my $DBH=undef;

#-----------------------------------
my $TAB_DEVICES_NAME = 'devices';
my %TAB_DEVICES = (
        id_dev => '?',
        name => '?',
        domain => '?',
        ip => '?',
        sysloc => '?',
        sysdesc => '',
        sysoid => '',
        txml => '',
        type => '',
);

#-----------------------------------
my $TAB_METRICS_NAME = 'metrics';
my %TAB_METRICS = (
        name => '?',
        id_dev => '?',
        type => '?',
        label => '?',
        items => '?',
        lapse => '?',
        file_path => '',
        file => '',
        host => '',
        vlabel=> '',
        graph=> '',
        other => '',
);

#-----------------------------------
#my $TAB_METRICS1_NAME = 'cfg_metrics1';
#my %TAB_METRICS1 = (
#        id_metric => '?',
#        label => '?',
#        items => '?',
#        vlabel=> '',
#        graph=> '',
#        top_value => '',
#        mtype => '',
#);
#
##-----------------------------------
#my $TAB_METRICS2_NAME = 'cfg_metrics2';
#my %TAB_METRICS2 = (
#        id_dev => '?',
#        subtype => '?',
#        iid => '?',
#);

#-----------------------------------
my $TAB_ALERTS_NAME = 'alerts';
my %TAB_ALERTS = (
        id_alert => '?',
        id_device => '?',
        id_alert_type => '?',
        watch => '?',
        severity => '?',
        date => '?',
        ack => '?',
        counter => '',
);

#-----------------------------------
my $TAB_ALERTS_STORE_NAME = 'alerts_store';
my %TAB_ALERTS_STORE = (
        id_alert => '?',
        id_device => '?',
        id_alert_type => '?',
        watch => '?',
        severity => '?',
        date => '?',
        ack => '?',
        counter => '',
        date_store => '?',
);


#-----------------------------------
my $TAB_NOTIFICATIONS_NAME = 'notifications';
my %TAB_NOTIFICATIONS = (
        id_notif => '?',
        id_cfg_notification => '?',
        date => '?',
        rc => '?',
        msg => '?',
);


#-----------------------------------
my $TAB_CFG_NOTIFICATIONS_NAME = 'cfg_notifications';
my %TAB_CFG_NOTIFICATIONS = (
        id_cfg_notification => '?',
        id_device => '?',
        id_alert_type => '?',
        id_notification_type => '?',
        destino => '?',
        descr => '?',
        status => '?',
);


#-----------------------------------
my $TAB_CFG_EVENTS2ALERT_NAME = 'cfg_events2alerts';
my %TAB_CFG_EVENTTS2ALERT = (
        id_cfg_event2alert => '?',
        id_dev => '?',
        action => '?',
        severity => '?',
        txt => '?',
);


#-----------------------------------
my $TAB_NOTIFICATION_TYPE_NAME = 'notification_type';
my %TAB_NOTIFICATION_TYPE = (
        id_notification_type => '?',
        name => '?',
        dest_field => '?',
);

#-----------------------------------
my $TAB_ALERT_TYPE_NAME = 'alert_type';
my %TAB_ALERT_TYPE = (
        id_alert_type => '?',
        cause=> '?',
);


#-----------------------------------
my $TAB_SERVICES_NAME = 'services';
my %TAB_SERVICES = (
        id_serv => '?',
        name=> '?',
        description=> '?',
        type=> '?',
);


#-----------------------------------
my $TAB_REL_SERVICES_NAME = 'rel_services';
my %TAB_REL_SERVICES = (
        id_parent => '?',
        id_child=> '?',
        file=> '?',
);

#-----------------------------------
my $TAB_REL_DEV2ENT_NAME = 'rel_dev2ent';
my %TAB_REL_DEV2ENT = (
        id_dev => '?',
        id_ent => '?',
);

#-----------------------------------
my $TAB_METRIC2SNMP_NAME = 'metric2snmp';
my %TAB_METRIC2SNMP = (
        id_metric => '?',
        community => '?',
        oid => '?',
);

#-----------------------------------
my $TAB_METRIC2LATENCY_NAME = 'metric2latency';
my %TAB_METRIC2LATENCY = (
        id_metric => '?',
        monitor => '?',
        monitor_data => '?',
);

#-----------------------------------
my $TAB_METRIC2AGENT_NAME = 'metric2agent';
my %TAB_METRIC2AGENT = (
        id_metric => '?',
        monitor => '?',
        monitor_data => '?',
);


#-----------------------------------
my $TAB_EVENTS_NAME = 'events';
my %TAB_EVENTS = (
        date => '?',
        code => '?',
        proccess => '?',
        msg => '?',
        ip => '?',
        name => '?',
        domain => '?',
);


#-----------------------------------
my $TAB_CFG_ASSIGNED_METRICS_NAME = 'cfg_assigned_metrics';
my %TAB_CFG_ASSIGNED_METRICS = (
        id_assigned_metric => '?',
        range => '?',
        id_type => '?',
        include => '?',
        lapse => '?',
        type => '?',
        subtype => '?',
        monitor => '?',
);

#-----------------------------------
my $TAB_CFG_MONITOR_SNMP_NAME = 'cfg_monitor_snmp';
my $TAB_CFG_MONITOR_AGENT = 'cfg_monitor_agent';
my $TAB_CFG_MONITOR = 'cfg_monitor';

#limpiezafml
#my $TAB_DEVICE2FEATURES = 'device2features';
#
#my $TAB_APP2DEVICE = 'app2device';
my $TAB_CFG_REGISTER_APPS ='cfg_register_apps';
my $TAB_CFG_DEVICE2ORGANIZATIONAL_PROFILE='cfg_devices2organizational_profile';
my $TAB_ALERTS_FIFO_NAME='alerts_fifo';
my $TAB_QACTIONS='qactions';

my $TSTART_MIN_ALLOWED=1230000000;

# id_dev, id_feature, feature_type

#----------------------------------------------------------------------------
# Funcion: Constructor
# Descripcion: Crea un objeto del tipo Crawler::Store
#----------------------------------------------------------------------------
sub new {
my ($class,%arg) =@_;

   my $self=$class->SUPER::new(%arg);

	my %DB=();
	$DB{DRIVERNAME}='mysql';	
	$DB{PORT}=3306;	
	if (defined $arg{db_server}) { $DB{'SERVER'}=$arg{db_server}; }
	if (defined $arg{db_port}) { $DB{'PORT'}=$arg{db_port}; }
	if (defined $arg{db_name}) { $DB{'DATABASE'}=$arg{db_name};}
	if (defined $arg{db_user}) { $DB{'USER'}=$arg{db_user}; }
	if (defined $arg{db_pwd}) { $DB{'PASSWORD'}=$arg{db_pwd}; }
	$DB{'DEBUG'} = (defined $arg{db_debug}) ? $arg{db_debug} : 0;
   $self->{_db} = \%DB;

	$self->{_error} = $arg{error} || 0;
	$self->{_errorstr} = $arg{errorstr} || '';
	$self->{_lastcmd} = $arg{lastcmd} || '';
	$self->{_response} = $arg{response} || '';

	$self->{_table_data} = $arg{table_data} || {};

	$self->{_version1} = $arg{version1} || '3.23.54';
	$self->{_version2} = $arg{version2} || '1.0.40';

   return $self;

}

#----------------------------------------------------------------------------
# db
#----------------------------------------------------------------------------
sub db {
my ($self,$cfg) = @_;
   if (defined $cfg) {
      $self->{_db}=$cfg;
   }
   else { return $self->{_db}; }
}

#----------------------------------------------------------------------------
# error
#----------------------------------------------------------------------------
sub error {
my ($self,$error) = @_;
   if (defined $error) {
      $self->{_error}=$error;
   }
   else { return $self->{_error}; }
}


#----------------------------------------------------------------------------
# errorstr
#----------------------------------------------------------------------------
sub errorstr {
my ($self,$errorstr) = @_;
   if (defined $errorstr) {
      $self->{_errorstr}=$errorstr;
   }
   else { return $self->{_errorstr}; }
}


#----------------------------------------------------------------------------
# lastcmd
#----------------------------------------------------------------------------
sub lastcmd {
my ($self,$lastcmd) = @_;
   if (defined $lastcmd) {
		$lastcmd =~ s/\n/\.\./g;
      $self->{_lastcmd}=$lastcmd;
   }
   else { return $self->{_lastcmd}; }
}

#----------------------------------------------------------------------------
# response 
#----------------------------------------------------------------------------
sub response {
my ($self,$response) = @_;
   if (defined $response) {
      $self->{_response}=$response;
   }
   else { return $self->{_response}; }
}


#----------------------------------------------------------------------------
# version1
#----------------------------------------------------------------------------
sub version1 {
my ($self,$version) = @_;
   if (defined $version) {
      $self->{_version1}=$version;
   }
   else { return $self->{_version1}; }
}

#----------------------------------------------------------------------------
# version2
#----------------------------------------------------------------------------
sub version2 {
my ($self,$version) = @_;
   if (defined $version) {
      $self->{_version2}=$version;
   }
   else { return $self->{_version2}; }
}

#----------------------------------------------------------------------------
# table_data
#----------------------------------------------------------------------------
sub table_data {
my ($self,$table_data) = @_;
   if (defined $table_data) {
      $self->{_table_data}=$table_data;
   }
   else { return $self->{_table_data}; }
}



#----------------------------------------------------------------------------
# find_rrd
#----------------------------------------------------------------------------
sub find_rrd  {
my ($self,$device,$subdir,$type,$name)=@_;

   my $store_path= $self->store_path();
   if (! $store_path) {$store_path='/opt/';}
   my $n=lc $device;
   my $rrd=$store_path.$self->store_subdir($subdir).$n.'/'.$n.'-'.$type.'-'.$name.'.rrd';
	return $rrd;

}	

#----------------------------------------------------------------------------
# Funcion: create_rrd
# Descripcion:
#----------------------------------------------------------------------------
sub create_rrd  {
my ($self,$rrd,$items,$mode,$lapse,$start,$type,$min,$max)=@_;

   if (! defined $start) {$start=time;}
   if (!defined $min) {$min='U';}
   if (!defined $max) {$max='U';}

	#if ($mode =~ /counter/i) {$mode = uc $mode; }
	# El modo counter se cambia por DERIVE para evitar que los reseteos de
	# maquina o los overflows en los datos recibidos generen valores
	# espureos en las graficas.
	if ($mode =~ /counter/i) {
		$mode = 'DERIVE';
		$min=0;	
	}
	elsif ($mode =~ /gauge/i) {$mode = uc $mode; }
	else {
		$self->log('warning',"create_rrd::[WARN] Tipo $mode no soportado");
		return 1;
	}

	my $heartbeat=2*$lapse;

	if ($rrd=~/^(.*)\/[^\/]*/) {	
		my $base_dir=$1;
		if (! -d $base_dir) { mkdir $base_dir; }
	}

	if (defined $type) {

		my ($create,$graph)=split('_',$type,2);
		if (defined $CREATE{$create}){

	      my @ds=();
        	for (1..$items) {
                	my $d="DS:value$_:$mode:$heartbeat:$min:$max";
                	push @ds,$d;
        	}

			my $rra=$CREATE{$create};
			RRDs::create ($rrd, "--start",$start-1, "--step",$lapse, @ds, @$rra);
		}
		else {
      	$self->log('warning',"create_rrd::[WARN] Datos para crear rrd no soportados ($create)");
     	 	return 1;
   	}

	}
	else {

     	$self->log('warning',"create_rrd::[WARN] No definido el tipo para crear el rrd");
  	 	return 1;

#	   RRDs::create ($rrd, "--start",$start-1, "--step",$lapse, @ds,
#               "RRA:AVERAGE:0.5:1:600",
#               "RRA:AVERAGE:0.5:6:700",
#               "RRA:AVERAGE:0.5:24:775",
#               "RRA:AVERAGE:0.5:288:797",
#               "RRA:MAX:0.5:1:600",
#               "RRA:MAX:0.5:6:700",
#               "RRA:MAX:0.5:24:775",
#               "RRA:MAX:0.5:288:797",
#   	);

	}
	if ( -e $rrd ) { chmod 0666,$rrd; }

   my $error = RRDs::error;
   if ($error) { $self->log('warning',"create_rrd::[WARN] al crear rrd ($mode/$items): $rrd ($error) step=$lapse start=$start type=$type min=$min max=$max");}
  	#else { $self->log('debug',"create_rrd::[DEBUG] Creado $rrd start=$start, step=$lapse, heart=$heartbeat");}
	return 1;
}


#----------------------------------------------------------------------------
# Funcion: update_rrd
# Descripcion:
#----------------------------------------------------------------------------
sub update_rrd  {
my ($self,$rrd,$data)=@_;


 eval {

	$self->log('debug',"update_rrd::[DEBUG] Voy a actualizar $rrd con $data");

#	my $file_lock='/tmp/.rrd.lock';
#	if (! -f $file_lock) { `/bin/touch $file_lock`; }
#	open(LOCK,">$file_lock");
#	print LOCK "PID=$$ RRD=$rrd DATA=$data\n";
#	flock LOCK, 2;


   RRDs::update ($rrd, "$data");
   my $error = RRDs::error;
   if ($error) {

		#/opt/data/rrd/elements/0000001279/custom_7250446f-STD.rrd: illegal attempt to update using time 1467052800 when last update time is 1467052800 (minimum one second step)
		# Un reinicio antes del lapse hace que al almacenar los datos en metricas de tipo gauge el timestamp se pueda repetir.
		# Eso genera un error que realmente no lo es.
		if ($error =~ /illegal attempt to update using time (\d+) when last update time is (\d+)/) {
			if ($1 == $2) { return 0; }
		}

		$self->log('warning',"update_rrd::[WARN] al actualizar rrd: $rrd con $data ($error)");
		# Un error habitual es algo asi
		# expected 4 data source readings (got 2) from 1235760611:20939727:20939727:...
		# found extra data on update argument: 0:21:33:1:0:8:0:0:0:47:2:2:4:0
		if (	($error =~ /expected \d+ data source readings/) || 
				($error =~ /found extra data on update argument/)   ) { 

			my $rc = unlink $rrd;
         $self->log('warning',"update_rrd::[WARN] Eliminado rrd $rrd ($rc)");
         return 1;
		}
	}
	# Demasiada cera para syslog
	else { $self->log('debug',"update_rrd::[DEBUG] Actualizado $rrd con $data");}

#   flock LOCK, 8;
#   close LOCK;


 };
 if ($@) { $self->log('error',"update_rrd::[ERROR] **EXCEPCION** ($@)"); }

	return 0;


}

#----------------------------------------------------------------------------
# Funcion: put_rrd_data
# Descripcion:
#----------------------------------------------------------------------------
sub put_rrd_data  {
my ($self,$params)=@_;

	my $rrd = (exists $params->{'rrd'}) ? $params->{'rrd'} : '';
	my $lapse = (exists $params->{'lapse'}) ? $params->{'lapse'} : 300;
	my $t = (exists $params->{'t'}) ? $params->{'t'} : 0;
	my $values = (exists $params->{'values'}) ? $params->{'values'} : [];
	my $items = (exists $params->{'items'}) ? $params->{'items'} : '';
	my $mode = (exists $params->{'mode'}) ? $params->{'mode'} : 'COUNTER';
	my $type = (exists $params->{'type'}) ? $params->{'type'} : '';
	my $task_id = (exists $params->{'task_id'}) ? $params->{'task_id'} : '';

	my $N=2;
	my $tx = $t-$N*$lapse;

	#----------------------------------------------------------
   if (! -e $rrd) {
		$self->create_rrd($rrd,$items,$mode,$lapse,$tx,$type);
$self->log('info',"put_rrd_data::[DEBUG ID=$task_id] NO EXISTE $rrd -> LO CREO");
		my $i=$N;
      while ($i>0) {
      	my $dx=join(':',$tx,@$values);
         $self->update_rrd($rrd,$dx);
$self->log('info',"put_rrd_data::[DEBUG ID=$task_id] UPDATE $rrd -> $dx");
         $tx+=$lapse;
			$i--;
      }
   }

	#----------------------------------------------------------
	my $data=join(':',$t,@$values);
	my	$r = $self->update_rrd($rrd,$data);
$self->log('debug',"put_rrd_data::[DEBUG ID=$task_id] UPDATE NORMAL ($lapse) $rrd -> $data");

	#----------------------------------------------------------
   if ($r) {
      my $ru = unlink $rrd;
      $self->log('info',"put_rrd_data::[DEBUG ID=$task_id] Elimino $rrd  ($ru)");

		$tx = ($lapse == 3600) ? $t-(12+$N)*$lapse : $t-$N*$lapse;
      $self->create_rrd($rrd,$items,$mode,$lapse,$tx,$type);
$self->log('info',"put_rrd_data::[DEBUG ID=$task_id] NO EXISTE $rrd -> LO CREO");
		my $i=$N;
      while ($i>0) {
	      my $dx=join(':',$tx,@$values);
   	   $self->update_rrd($rrd,$dx);
$self->log('info',"put_rrd_data::[DEBUG ID=$task_id] UPDATE $rrd -> $dx");
      	$tx+=$lapse;
			$i--;
   	}

	   #----------------------------------------------------------
	   my $data=join(':',$t,@$values);
   	my $r = $self->update_rrd($rrd,$data);
$self->log('info',"put_rrd_data::[DEBUG ID=$task_id] UPDATE NORMAL1 ($lapse) $rrd -> $data");

	}

}


#----------------------------------------------------------------------------
# Funcion: fetch_rrd
# Descripcion:
#----------------------------------------------------------------------------
sub fetch_rrd  {
my ($self,$rrd)=@_;
my $rc=undef;

	my %DATA=();	
  	my ($start,$step,$names,$data) = RRDs::fetch $rrd, "AVERAGE";

	my $error = RRDs::error;
   if ($error) { $self->log('warning',"fetch_rrd::[WARN] FECTH rrd $rrd ");}

	my $dstart=scalar localtime($start);
	$dstart.="($start)";
	my $dstep=$step;
	my $dsnames=join (", ", @$names);
	my $dpoints=scalar @$data;
	$self->log('debug',"fetch_rrd::[DEBUG] FETCH $dstart,$dstep,[$dsnames],$dpoints ($rrd) ");

	foreach my $line (@$data){
		my $i=0;
		my %vals=();
   	foreach my $val (@$line) {
			$i+=1;
      	if (! $val) { next; }
			my $x='v'.$i;
			$vals{$x}=sprintf "%12.1f", $val;
  		}

		# -----------------------------
		$vals{'usage'}='U';
		if ($vals{'v1'} != 0) {
			$vals{'usage'}=sprintf "%3.2f", ($vals{'v2'}/$vals{'v1'})*100;
		}
		# -----------------------------
		$DATA{$start}=\%vals;
	   $start += $step;
	}


#	if (defined $rc) { $self->log('debug',"fetch_rrd::[DEBUG] FETCH $rc ($rrd)");}
#	else {$self->log('warning',"fetch_rrd::[WARN] FETCH ($v):UNDEF ($rrd)");}

	return \%DATA;
}



#----------------------------------------------------------------------------
# Funcion: rrd2db
# Descripcion:
#----------------------------------------------------------------------------
sub rrd2db  {
my ($self,$rrd,$start,$end)=@_;
my $rc=undef;


   my ($start1,$step,$names,$data) = RRDs::fetch ($rrd, "--start=$start", "--end=$end", "AVERAGE");

   my $error = RRDs::error;
   if ($error) { $self->log('warning',"fetch_rrd::[WARN] FECTH rrd $rrd ");}


   print "Start:       ", scalar localtime($start1), " ($start1)\n";
   print "Step size:   $step seconds\n";
   print "DS names:    ", join (", ", @$names)."\n";
   print "Data points: ", $#$data + 1, "\n";
   print "Data:\n";
   for my $line (@$data) {
      print "  ", scalar localtime($start1), " ($start1) ";
      $start1 += $step;
      for my $val (@$line) {
         printf "%12.6f ", $val;
      }
      print "\n";
  }

   return $rc;
}



#----------------------------------------------------------------------------
# Funcion: fetch_rrd_last
# Descripcion:
#----------------------------------------------------------------------------
sub fetch_rrd_last  {
my ($self,$rrd)=@_;

	my $rrd_file=$self->store_path().$self->store_subdir('elements').$rrd;
	if (! -f $rrd_file) {
		$self->log('warning',"fetch_rrd_last::[WARN] No existe fichero $rrd_file ");
		return undef;
	}

	my $tnow=time;
	my ($start,$step,$names,$array) = RRDs::fetch $rrd_file, "AVERAGE", "-s $tnow";
	my $delta=(2*$step)+30;
	$tnow -= $delta;
	#$tnow -= 650;
	($start,$step,$names,$array) = RRDs::fetch $rrd_file, "AVERAGE", "-s $tnow";

   my $error = RRDs::error;
   if ($error) { $self->log('warning',"fetch_rrd_last::[WARN] FECTH rrd $rrd_file");}

#my $nn=@$names;
#my $kk=$array->[1];
#$self->log('warning',"fetch_rrd_last::[WARN] **FML**FECTH rrd FILE=$rrd_file START=$start STEP=$step NAMES=$names");
#$self->log('warning',"fetch_rrd_last::[WARN] **FML**FECTH rrd NAMES=$nn");
#$self->log('warning',"fetch_rrd_last::[WARN] **FML**FECTH rrd @$array (@$kk)");

	my @result=();
	foreach my $v (@{$array->[0]}) { 
		if ( (defined $v) && ($v=~/\d+/) ) {
			push @result, sprintf("%.6f", $v); 
		}
	}
	return \@result;
#	return $array->[0];
}


#----------------------------------------------------------------------------
# Funcion: store_previous
# Descripcion:
#----------------------------------------------------------------------------
sub store_previous  {
my ($self,$values,$rrd)=@_;

	if (! -d $DIR_COUNTER_DATA) { `/bin/mkdir -p $DIR_COUNTER_DATA`; }

	$rrd =~ s/\//\-/g;
	my $f = $DIR_COUNTER_DATA.'/'.$rrd;
 	open (F,">$f");
	print F $values;
	close F;
 
}

#----------------------------------------------------------------------------
# Funcion: get_previous
# Descripcion:
#----------------------------------------------------------------------------
sub get_previous  {
my ($self,$rrd)=@_;

	my $content='U';
	$rrd =~ s/\//\-/g;
	my $f = $DIR_COUNTER_DATA.'/'.$rrd;
	if (-f $f) {
	   local($/) = undef;  # slurp
   	open (F,"<$f");
   	$content = <F>;
   	close F;
	}

   return $content;
}


#            $items = scalar @$values;
#            $data=join(':',$t,@$values);

#----------------------------------------------------------------------------
# Funcion: get_delta_from_file
# Descripcion:
#----------------------------------------------------------------------------
sub get_delta_from_file  {
my ($self,$t,$values,$rrd)=@_;

	my @deltas=();
	my $data0=$self->get_previous($rrd);
	# $data0 tiene formato ts:v1:...:vn o 'U'
	# data0=1467099004:101332736:38371525:1772654221
	# data0=U Si no existe el fichero especificado
	# ej. /opt/data/mdata/counter/0000000953-ucd_cpu4_raw_usage-STD.rrd
$self->log('info',"get_delta_from_file:: ****get_previous**** data0=$data0 file=$rrd");
	if ($data0 eq 'U') { 
		return \@deltas;
	}
	my @d0=split(':',$data0);
	my $t0=shift(@d0);
	my $lapse=$t-$t0;

	if ($lapse<=0) {
		$self->log('info',"get_delta_from_file:: **SIN DATOS** lapse=$lapse");
		return \@deltas;
	}
	my $items = scalar @$values;
	foreach my $i (0..$items-1) {
		push @deltas, ($values->[$i]-$d0[$i])/$lapse;
	}

	my $data=join(':',$t,@$values);
	$self->store_previous($data,$rrd);
$self->log('info',"get_delta_from_file::lapse=$lapse ****store_previous**** data=$data");

	return \@deltas;

}

#----------------------------------------------------------------------------
# Funcion: store_cfg_network
# Descripcion:
#----------------------------------------------------------------------------
sub store_cfg_network {
my ($self,$dbh,$data)=@_;
my $rv=undef;

   # Compongo la condicion de Insert/Update (PK=ip+host_idx, K=id_dev) ------------
   # Opciones  a) id_dev  b) ip+host_idx --------------------------------
   my %table=();
   if ( (exists $data->{'network'}) && ($data->{'network'}=~/\d+\.\d+.\d+.\d+\/\d+/)) { 
		$table{'network'} = $data->{'network'}; 
	}
	else {
		if (!exists $data->{'network'}) { $data->{'network'}=''; }
		$self->log('warning',"store_cfg_network::[WARN] ERROR conel parametro network ($data->{'network'})");
		return;
	}

   if (exists $data->{'mode'}) { $table{'mode'} = $data->{'mode'}; }
   if (exists $data->{'descr'}) { $table{'descr'} = $data->{'descr'}; }


   $rv=sqlInsert($dbh,'cfg_networks',\%table);
   $self->error($libSQL::err);
   $self->errorstr($libSQL::errstr);
   $self->lastcmd($libSQL::cmd);
	# No me preocupa el error. Si la red ya existe siempre va a fallar 
}



#----------------------------------------------------------------------------
# Funcion: store_device
# Descripcion:
#----------------------------------------------------------------------------
sub store_device {
my ($self,$dbh,$data)=@_;
my $rv=undef;
my @c=();
my $condition;
my $rres;
my $new_id_dev;

	# Compongo la condicion de Insert/Update (PK=ip+host_idx, K=id_dev) ------------
	# Opciones  a) id_dev  b) ip+host_idx --------------------------------
	my %table=();
   if ($data->{'id_dev'}) {
      $table{'id_dev'}=$data->{'id_dev'};
      $condition="id_dev=$data->{id_dev}";
   }
   elsif ( ($data->{'ip'}) &&  ($data->{'host_idx'}) ){
		push @c,  "ip=\'$data->{ip}\' and host_idx=\'$data->{host_idx}\'";
      $condition=join (' && ',@c);
   }
	# Por ser mas permisivo (cuidadin)
   elsif ($data->{'ip'}) {
      push @c,  "ip=\'$data->{ip}\'";
      $condition=join (' && ',@c);
   }
   else {
      $self->log('warning',"store_device::[ERROR] Faltan datos (id_dev|ip,host_idx)");
      return undef;
   }
# name&|&domain&|&ip&|&sysloc&|&sysdesc&|&sysoid&|&type&|&status&|&community&|&version&|&perfil_organizativo&|&host_idx&|&wbem_user&|&wbem_pwd
	#------------------------------------------------------------------------
   if ($data->{'id_dev'}) {$table{'id_dev'}=$data->{'id_dev'};}
   if ($data->{'ip'}) {$table{'ip'}=$data->{'ip'};}
   if ($data->{'name'}) {$table{'name'}=lc $data->{'name'};}
   if ($data->{'domain'}) {$table{'domain'}= lc $data->{'domain'};}

   if (defined $data->{'sysloc'}) {$table{'sysloc'}=$data->{'sysloc'};}
   if (defined $data->{'sysdesc'}) {$table{'sysdesc'}=$data->{'sysdesc'};}
   if (defined $data->{'sysoid'}) {$table{'sysoid'}=$data->{'sysoid'};}
   elsif (defined $data->{'oid'}) {$table{'sysoid'}=$data->{'sysoid'};}
   if (defined $data->{'enterprise'}) {$table{'enterprise'}=$data->{'enterprise'};}

   #if (defined $data->{'txml'}) {$table{'txml'}=$data->{'txml'};}
   if (defined $data->{'app'}) {$table{'app'}=$data->{'app'};}

   if (defined $data->{'type'}) {$table{'type'}=$data->{'type'};}
   if (defined $data->{'status'}) {$table{'status'}=$data->{'status'};}
   if (defined $data->{'community'}) {$table{'community'}=$data->{'community'};}
   if (defined $data->{'version'}) {$table{'version'}=$data->{'version'};}
   if (defined $data->{'mode'}) {$table{'mode'}=$data->{'mode'};}
   if (defined $data->{'mac'}) {$table{'mac'}=$data->{'mac'};}
   if (defined $data->{'mac_vendor'}) {$table{'mac_vendor'}=$data->{'mac_vendor'};}
   if (defined $data->{'critic'}) {$table{'critic'}=$data->{'critic'};}

   if (defined $data->{'host_idx'}) {$table{'host_idx'}=$data->{'host_idx'};}
   if (defined $data->{'background'}) {$table{'background'}=$data->{'background'};}
   if (defined $data->{'wbem_user'}) {$table{'wbem_user'}=$data->{'wbem_user'};}
   if (defined $data->{'wbem_pwd'}) {$table{'wbem_pwd'}=$data->{'wbem_pwd'};}

   if (defined $data->{'geodata'}) {$table{'geodata'}=$data->{'geodata'};}

   if (defined $data->{'network'}) {$table{'network'}=$data->{'network'};}
   if (defined $data->{'switch'}) {$table{'switch'}=$data->{'switch'};}

	#------------------------------------------------------------------------
	$rv=sqlInsertUpdate4x($dbh,$TAB_DEVICES_NAME,\%table,\%table);
   $self->error($libSQL::err);
   $self->errorstr($libSQL::errstr);
   $self->lastcmd($libSQL::cmd);

   if ($libSQL::err) {
      #$self->log('warning',"store_device::[WARN] ERROR $libSQL::err  en Insert device $table{name} ($libSQL::cmd)");
		$self->manage_db_error($dbh,"store_device INSERT");
      return undef;
   }

	$rres=sqlSelectAll($dbh,'id_dev',$TAB_DEVICES_NAME,$condition);
   $self->log('debug',"store_device::[DEBUG] Insert device [ID=$rres->[0][0]] (RV=$rv) (condition=$condition)");
	$new_id_dev=$rres->[0][0];
   return $new_id_dev;

}


#----------------------------------------------------------------------------
# Funcion: store_device_record
# Descripcion:
#----------------------------------------------------------------------------
sub store_device_record {
my ($self,$dbh,$ip)=@_;
my $rv=undef;
my @c=();
my $condition;
my $rres;
my $new_id_dev;

	my $lang = $self->core_i18n_global();

   my $description='';
   # 1. Obtener los campos basicos del dispositivo
   $rres=sqlSelectAll($dbh,'id_dev,name,domain,type,community,status,mac,mac_vendor,critic,wsize',$TAB_DEVICES_NAME,"ip='$ip'");
   my $id_dev=$rres->[0][0];
   $description .= $lang->{'_name'}.': '.$rres->[0][1]."\n";
   $description .= $lang->{'_domain'}.': '.$rres->[0][2]."\n";
   $description .= $lang->{'_ip'}.': '.$ip."\n";
   $description .= $lang->{'_snmpcommunity'}.': '.$rres->[0][4]."\n";
	my $mac_info='-';
	if ($rres->[0][6] != 0) { 
		$mac_info=$rres->[0][6].' ('.$rres->[0][7].')';
	}
   $description .= $lang->{'_mac'}.': '.$mac_info."\n";
   $description .= $lang->{'_criticity'}.': '.$rres->[0][8].' '.$lang->{'_outof100'}."\n";
   $description .= $lang->{'_type'}.': '.$rres->[0][3]."\n";
	$description .= $lang->{'_status'}.': ';
   if ($rres->[0][5]==0){ $description .= $lang->{'_active'}."\n";  }
   elsif ($rres->[0][5]==1){ $description .= $lang->{'_unmanaged'}."\n"; }
   elsif ($rres->[0][5]==2){ $description .= $lang->{'_maintenance'}."\n"; }

	$description .= $lang->{'_alertssensitivity'}.': ';
   if ($rres->[0][9]==0){ $description .= $lang->{'_normal'}."\n";  }
   elsif ($rres->[0][9]==5){ $description .= $lang->{'_low'}."\n";  }
   elsif ($rres->[0][9]==10){ $description .= $lang->{'_verylow'}."\n";  }

#mysql> select * from cfg_device_wsize;
#+-------+----------+
#| wsize | label    |
#+-------+----------+
#|     0 | Normal   |
#|     5 | Baja     |
#|    10 | Muy Baja |
#+-------+----------+

   # 2. Obtener los campos definidos por el usuario
   #$rres=sqlSelectAll($dbh,'id_descr','devices_custom_types');
   $rres=sqlSelectAll($dbh,'id,descr,tipo','devices_custom_types');
   foreach my $r (@$rres) {
		my $type = $r->[2];
		$description.= $r->[1];
      my $col='columna'.$r->[0];
      my $rres1=sqlSelectAll($dbh,$col,'devices_custom_data',"id_dev=$id_dev");

		# Se comprueba si es de tipo url (2)
      if ( ($type == 2) && ($rres1->[0][0] ne '-') ) {
         my $href="<a href='__URL__' target='_blank' style='color=#0000CC;text-decoration=underline'> __URL__ </a>";
         my $url = $rres1->[0][0];
         $href =~ s/__URL__/$url/g;
         $description.=": ".$href."\n";
      }
      else {
	      $description.=": ".$rres1->[0][0]."\n";
		}
   }
   # 3. Obtener los perfiles organizativos a los que pertenece el dispositivo
   my $sql="SELECT descr
         FROM cfg_organizational_profile
         WHERE id_cfg_op IN (
                              SELECT id_cfg_op
                              FROM cfg_devices2organizational_profile
                              WHERE id_dev=$id_dev)";

   $description .= $lang->{'_organizationalprofiles'}.': ';
   $rres=sqlSelectAllCmd($dbh,$sql,'');
   foreach my $r (@$rres) {
      $description.=$r->[0].',';
   }
   $description =~ s/,$//;

   # 4. Insertar los datos en una nota del dispositivo
   my $date=time;
   $rres=sqlSelectAll($dbh,'id_tip','tips',"tip_class=1 and id_ref=$id_dev");

	my $id_tip=$rres->[0][0];
	my $name = $lang->{'_docdevicesummary'};
   my %table = ( 'id_ref'=>$id_dev, 'tip_type'=>'id_dev', 'name'=>$name, 'date'=>$date, 'tip_class'=>1, 'descr'=>$description );
	if (defined $id_tip) { $table {'id_tip'}=$id_tip; }

   $rv=sqlInsertUpdate4x($dbh,'tips',\%table,\%table);

my $sqlc=$libSQL::cmd;
$sqlc=~s/\n/ /g;
	$self->log('info',"store_device_record:: **DEBUG** $sqlc ($libSQL::err : $libSQL::errstr)");

}




#----------------------------------------------------------------------------
# Funcion: store_device_custom_data
# Descripcion:
#----------------------------------------------------------------------------
sub store_device_custom_data {
my ($self,$dbh,$id_dev,$data)=@_;
my $rv=undef;


   #------------------------------------------------------------------------
	$data->{'id_dev'} = $id_dev;

   #------------------------------------------------------------------------
   $rv=sqlInsertUpdate4x($dbh,'devices_custom_data',$data,$data);
   $self->error($libSQL::err);
   $self->errorstr($libSQL::errstr);
   $self->lastcmd($libSQL::cmd);

   if ($libSQL::err) {
      #$self->log('warning',"store_device_custom_data::[WARN] ERROR $libSQL::err  en insert/update ($libSQL::cmd)");
		$self->manage_db_error($dbh,"store_device_custom_data");
      return undef;
   }
}



#----------------------------------------------------------------------------
# Funcion: clear_device
# Descripcion:
#----------------------------------------------------------------------------
sub clear_device {
my ($self,$dbh,$data)=@_;
my %table=();
my $rv=undef;
my $condition='';

   if (defined $data->{id_dev}) { $condition="id_dev=$data->{id_dev}"; }
	elsif (defined $data->{name}) { $condition="name=\'$data->{name}\'"; }
	elsif (defined $data->{ip}) { $condition="ip=\'$data->{ip}\'"; }
	elsif (defined $data->{type}) { $condition="type=\'$data->{type}\'"; }
   else {return undef;}

#print "cc=$condition\n";
	if (!defined $data->{status}) { sqlDelete($dbh,$TAB_DEVICES_NAME,$condition); }
	else {
		$table{status}=$data->{status};
#print "CC=$condition\n";
	   sqlUpdate($dbh,$TAB_DEVICES_NAME,\%table,$condition);
	}
}


#----------------------------------------------------------------------------
# Funcion: get_device
# Descripcion:
#----------------------------------------------------------------------------
sub get_device {
my ($self,$dbh,$data,$values)=@_;
my @c=();

	if (defined $data->{id_dev}) { push @c, "id_dev in ($data->{id_dev})"; }
	elsif (defined $data->{in}) { push @c, "ip in ($data->{in})"; }
	else {

   	if (defined $data->{name}) {
			$data->{name} =~ s/\*/%/g;
			push @c, "name like \'$data->{name}\'";
      	if (defined $data->{domain}) {
				$data->{domain} =~ s/\*/%/g;
				push @c, "domain like \'$data->{domain}\'";
			}
   	}

   	if (defined $data->{ip}) {
			$data->{ip} =~ s/\*/%/g;
			push @c, "ip like \'$data->{ip}\'";
		}

		if (defined $data->{type}) {
			$data->{type} =~ s/\*/%/g;
			push @c, "type like \'$data->{type}\'";
		}
		if (defined $data->{txml}) {
			$data->{txml} =~ s/\*/%/g;
 			push @c, "txml like \'$data->{txml}\'";
		}
		if (defined $data->{app}) {
			$data->{app} =~ s/\*/%/g;
			push @c, "app like \'$data->{app}\'";
		}
      if (defined $data->{dyn}) {
         push @c, "dyn = $data->{dyn}";
      }
	}

	if (defined $data->{status}) {  push @c, "status=\'$data->{status}\'"; }

	if (! scalar @c) {return undef;}
	
	my $condition=join (' && ',@c);

	if (!defined $values) {$values='id_dev,name,domain,ip,sysoid,status,txml,app'; }

   my $rres=sqlSelectAll($dbh,$values,$TAB_DEVICES_NAME,$condition);
   return $rres;

}

#----------------------------------------------------------------------------
# Funcion: get_device_attributes
# Descripcion:
# Returns hash with fields:
# __TYPE__ __SYSOID__ __SYSDESC__ __SYSLOC__ __STATUS__ __COMMUNITY__ __VERSION__
# __CRITIC__ __MAC__ __MACVENDOR__ __GEODATA__
# + __CUSTOM FIELDS__ ....
#----------------------------------------------------------------------------
sub get_device_attributes {
my ($self,$dbh,$id_dev)=@_;
my @c=();

	my %INFO=();
   #my $rres=sqlSelectAll($dbh,'id,descr,tipo','devices');

	my %attr_label=(); #e.j: columna1->Proveedor
	my %attr_data=(); #e.j: columna1->indra

	my $DEV_COLS='a.type,a.sysoid,a.sysdesc, a.sysloc,a.status,a.community,a.version,a.critic,a.mac,a.mac_vendor,a.geodata'; #***1****
	my @cols = split (',', $DEV_COLS);
   my $rres=sqlSelectAll($dbh,'id,descr,tipo','devices_custom_types','','order by id');
	my @keys_in_order = ();
   foreach my $r (@$rres) {
		my $key='b.columna'.$r->[0];
		push @keys_in_order,$key;
		$attr_label{$key} = $r->[1];
		push @cols, $r->[0];
	}

	my $what = $DEV_COLS;
	if (scalar @keys_in_order > 0) { $what .= ',' . join ',', @keys_in_order; }

	$rres=sqlSelectAll($dbh,$what,'devices a, devices_custom_data b',"a.id_dev=b.id_dev AND a.id_dev=$id_dev");
	$INFO{'__TYPE__'} = $rres->[0][0];
	$INFO{'__SYSOID__'} = $rres->[0][1];
	$INFO{'__SYSDESC__'} = $rres->[0][2];

	$INFO{'__SYSLOC__'} = $rres->[0][3];
	$INFO{'__STATUS__'} = $rres->[0][4];
	$INFO{'__COMMUNITY__'} = $rres->[0][5];
	$INFO{'__VERSION__'} = $rres->[0][6];
	$INFO{'__CRITIC__'} = $rres->[0][7];
	$INFO{'__MAC__'} = $rres->[0][8];
	$INFO{'__MACVENDOR__'} = $rres->[0][9];
	$INFO{'__GEODATA__'} = $rres->[0][10];

	#my $k=3;											#***3***
	my $k=11;											#***3***
	foreach my $i ($k..scalar(@cols)-1) {
		my $key='b.columna'.$cols[$i];
		my $attr = '__'. uc $attr_label{$key} . '__';
		$INFO{$attr} = $rres->[0][$i];	
		$self->log('debug',"get_device_attributes:: DEBUG i=$i key=$key attr=$attr >> $INFO{$attr}");
	}
	return \%INFO;
}


#----------------------------------------------------------------------------
# Funcion: get_cfg_networks
# Descripcion:
#+-----------------+--------------+------+-----+---------+----------------+
#| Field           | Type         | Null | Key | Default | Extra          |
#+-----------------+--------------+------+-----+---------+----------------+
#| id_cfg_networks | int(11)      | NO   | UNI | NULL    | auto_increment |
#| network         | varchar(50)  | NO   | PRI |         |                |
#| mode            | int(11)      | NO   |     | 0       |                |
#| descr           | varchar(255) | NO   |     |         |                |
#+-----------------+--------------+------+-----+---------+----------------+
#
#----------------------------------------------------------------------------
sub get_cfg_networks {
my ($self,$dbh,$data)=@_;
my @c=();
my @networks=();

	if (defined $data->{'network'}) {
      $data->{'network'} =~ s/\*/%/g;
      push @c, "network like \'".$data->{'network'}."\'";
   }
	elsif (defined $data->{'mode'}) {
      push @c, 'mode in ('.$data->{'mode'}.')';
   }

	my $condition=join (' && ',@c);
   my $rres=sqlSelectAll($dbh,'network','cfg_networks',$condition);
	foreach my $l (@$rres) { push @networks, $l->[0]; }
   return \@networks;

}

#----------------------------------------------------------------------------
# Funcion: store_metric
# Descripcion:
#----------------------------------------------------------------------------
sub store_metric {
my ($self,$dbh,$id_dev,$data)=@_;
my %table=();
my $rv=undef;

   if ($id_dev) {$table{'id_dev'}=$id_dev;}
	else {
      $self->log('warning',"store_metric::[WARN] No definido id_dev");
		return;
	}
   if (defined $data->{'name'}) {$table{'name'}=$data->{'name'};}
   if (defined $data->{'type'}) {$table{'type'}=$data->{'type'};}
   if (defined $data->{'subtype'}) {$table{'subtype'}=$data->{'subtype'};}
   if (defined $data->{'mtype'}) {$table{'mtype'}=$data->{'mtype'};}
   if (defined $data->{'label'}) {
		$table{'label'}=$data->{'label'};
		#---------------------------------
		if ( (defined $data->{'host_name'}) && (defined $data->{'domain'}) ) {
         my $hn=$data->{'host_name'};
         my $full_name=$hn.'.'.$data->{'domain'};
         ($data->{'domain'} ne '') ?  $table{'label'}=~s/__NAME__/$full_name/g
                                 :  $table{'label'}=~s/__NAME__/$hn/g;
		}
		#---------------------------------
	}
   if (defined $data->{'items'}) {$table{'items'}=$data->{'items'};}
   if (defined $data->{'lapse'}) {$table{'lapse'}=$data->{'lapse'};}
   if (defined $data->{'watch'}) {$table{'watch'}=$data->{'watch'};}
   if (defined $data->{'status'}) {$table{'status'}=$data->{'status'};}
   if (defined $data->{'severity'}) {$table{'severity'}=$data->{'severity'};}
   if (defined $data->{'file'}) { $table{'file'}=$data->{'file'};}
   if (defined $data->{'file_path'}) { $table{'file_path'}=$data->{'file_path'}; }
	else { $table{'file_path'}=$self->store_path().$self->store_subdir('elements'); }
	#if (defined $data->{'disk'}) { $table{'disk'}=$data->{'disk'}; }
	#else { $table{'disk'}=0; }


   if (defined $data->{'host'}) {$table{'host'}= lc $data->{'host'};}
   if (defined $data->{'graph'}) {$table{'graph'}=$data->{'graph'};}
	if (defined $data->{'mode'}) {$table{'mode'}=$data->{'mode'};}
	if (defined $data->{'module'}) {$table{'module'}=$data->{'module'};}
	if (defined $data->{'top_value'}) {$table{'top_value'}=$data->{'top_value'};}
	if (defined $data->{'refresh'}) {$table{'refresh'}=$data->{'refresh'};}

	if (defined $data->{'vlabel'}) {$table{'vlabel'}=$data->{'vlabel'};}
   else { $table{'vlabel'} = 'datos'; }

	$table{'severity'} = (defined $data->{'severity'}) ? $data->{'severity'} : 1 ;
	$table{'iid'} = (defined $data->{'iid'}) ? $data->{'iid'} : 'ALL' ;

	#------------------------------------------------------------
   $rv=sqlInsertUpdate4x($dbh,$TAB_METRICS_NAME,\%table,\%table);

   $self->error($libSQL::err);
   $self->errorstr($libSQL::errstr);
   $self->lastcmd($libSQL::cmd);


print "**FML**SQL=$libSQL::cmd\n";

   my $id_metric=undef;
   if ($libSQL::err==0) {

      my $rres=sqlSelectAll($dbh,'id_metric',$TAB_METRICS_NAME,"name = \'$table{name}\' && id_dev=\'$id_dev\'");
      $id_metric=$rres->[0][0];
      $self->log('debug',"store_metric::[DEBUG] MNAME=$table{name} ID_DEV=$table{id_dev} (ID_METRIC=$id_metric)");
      $self->log('debug',"store_metric::[DEBUG] T=$TAB_METRICS_NAME C=name = \'$table{name}\' && id_dev=\'$id_dev\'");
   }
	else { 
		$self->log('warning',"store_metric::[WARN] MNAME=$table{name} ID_DEV=$table{id_dev} ($libSQL::err : $libSQL::errstr)");
		my $sql=$libSQL::cmd;
		$sql =~ s/\n/ /g;
		$sql =~ s/\r/ /g;
		$self->log('warning',"store_metric::[WARN] SQL=$sql");
	}
   return $id_metric;




#   $rv=sqlInsert($dbh,$TAB_METRICS_NAME,\%table,0);
#   $self->error($libSQL::err);
#   $self->errorstr($libSQL::errstr);
#   $self->lastcmd($libSQL::cmd);
#
#	my $id_metric=undef;
#	if ($libSQL::err==0) {
#
#      my $rres=sqlSelectAll($dbh,'id_metric',$TAB_METRICS_NAME,"name = \'$table{name}\' && id_dev=\'$id_dev\'");
#      $id_metric=$rres->[0][0];
#      $self->log('debug',"store_metric::[DEBUG] Insert metric $table{name}.$table{id_dev} (ID_METRIC=$id_metric)");
#      return $id_metric;
#   }
#   $rv=sqlUpdate($dbh,$TAB_METRICS_NAME,\%table,"name = \'$table{name}\' && id_dev=\'$id_dev\'");
#   $self->error($libSQL::err);
#   $self->errorstr($libSQL::errstr);
#   $self->lastcmd($libSQL::cmd);
#
#   if (defined $rv) {
#      my $rres=sqlSelectAll($dbh,'id_metric',$TAB_METRICS_NAME,"name = \'$table{name}\' && id_dev=\'$id_dev\'");
#		$id_metric=$rres->[0][0];
#      $self->log('debug',"store_metric::[DEBUG] Update metric $table{name}.$table{id_dev} (ID_METRIC=$id_metric)");
#   }
#   else {
#      $self->log('warning',"store_metric::[WARN] Error en Insert/Update metric $table{name}.$table{id_dev} (RV=undef)");
#   }
#	return $id_metric;
#
}


#----------------------------------------------------------------------------
# Funcion: store_cfg_assigned_metric
# Descripcion:
#----------------------------------------------------------------------------
sub store_cfg_assigned_metric {
my ($self,$dbh,$data)=@_;
my %table=();
my $rv=undef;

   if (defined $data->{range}) {$table{myrange}=$data->{range};}
   if (defined $data->{id_type}) {$table{id_type}=$data->{id_type};}
	else { $table{id_type}=0; }
   if (defined $data->{include}) {$table{include}=$data->{include};}
   if (defined $data->{lapse}) {$table{lapse}=$data->{lapse};}
   if (defined $data->{type}) {$table{type}=$data->{type};}
   if (defined $data->{subtype}) {$table{subtype}=$data->{subtype};}
   if (defined $data->{monitor}) {$table{monitor}=$data->{monitor};}
   #if (defined $data->{active_iids}) {$table{active_iids}=$data->{active_iids};}
	$table{active_iids} = (defined $data->{active_iids}) ? $data->{active_iids} : 'all' ;

#print "  FML id_type=$table{id_type} \n";


   $rv=sqlInsertUpdate4x($dbh,$TAB_CFG_ASSIGNED_METRICS_NAME,\%table,\%table);

   $self->error($libSQL::err);
   $self->errorstr($libSQL::errstr);
   $self->lastcmd($libSQL::cmd);

#   $rv=sqlInsert($dbh,$TAB_CFG_ASSIGNED_METRICS_NAME,\%table);
#   $self->error($libSQL::err);
#   $self->errorstr($libSQL::errstr);
#   $self->lastcmd($libSQL::cmd);

   if ($libSQL::err) {
      #$self->log('warning',"store_cfg_assigned_metric::[WARN] range=$table{myrange} subtype=$table{subtype} ($libSQL::err)");
		$self->manage_db_error($dbh,"store_cfg_assigned_metric");
      return undef;
   }
   $self->log('debug',"store_cfg_assigned_metric::[DEBUG] Insert metric $table{myrange}:$table{subtype} (RV=$rv)");
   return $rv;


#   $rv=sqlUpdate($dbh,$TAB_CFG_ASSIGNED_METRICS_NAME,\%table,"range=\'$table{range}\' and subtype=\'$table{subtype}\'");
#   $self->error($libSQL::err);
#   $self->errorstr($libSQL::errstr);
#   $self->lastcmd($libSQL::cmd);

#   if (defined $rv) {
#      $self->log('debug',"store_cfg_assigned_metric::[DEBUG] Update metric $table{range}:$table{subtype} (RV=$rv)");
#   }
#   else {
#      $self->log('warning',"store_cfg_assigned_metric::[WARN] Error en Insert/Update metric $table{range}:$table{subtype} ($libSQL::err : $libSQL::errstr)");
#   }
#	return $rv;


}


#----------------------------------------------------------------------------
# Funcion: clear_alert
# Descripcion:
# $extra permite anexar algun texto en la parte del evento al guardar la alerta
# en alerts_history
#----------------------------------------------------------------------------
sub clear_alert {
my ($self,$dbh,$desc,$extra)=@_;

	my %table=();
   my $rres;
   my $condition;
   my $tab;

	my $sel='a.id_alert,a.id_device,a.id_alert_type,a.watch,a.severity,a.date,ack,a.counter,a.event_data,a.mname,a.notes,a.id_note_type,a.type,id_ticket,label,a.id_metric,a.subtype,a.name,a.domain,a.ip,a.cid,a.cid_ip,a.cause,a.date_last,a.critic,a.notif';

   if ($desc->{'id_alert'}) {
      $tab='alerts a';
      $condition="id_alert=$desc->{id_alert}";
   }
   elsif ( ($desc->{'ip'}) && ($desc->{'mname'}) ) {
#      $tab='alerts a,devices d';
#      $condition="a.id_device=d.id_dev and d.ip=\'$desc->{ip}\' and a.mname=\'$desc->{mname}\'";

      $tab='alerts a';
      $condition="a.ip=\'$desc->{ip}\' and a.mname=\'$desc->{mname}\'";

   }
   elsif ( ($desc->{'ip'}) && ($desc->{'id_metric'}) ) {
#      $tab='alerts a,devices d';
#      $condition="a.id_device=d.id_dev and d.ip=\'$desc->{ip}\' and a.id_metric=\'$desc->{id_metric}\'";

      $tab='alerts a';
      $condition="a.ip=\'$desc->{ip}\' AND a.id_metric=\'$desc->{id_metric}\'";
		if ($desc->{'type'}) { $condition .= " AND a.type=\'$desc->{type}\'"; }

   }

   else {
      $self->log('warning',"clear_alert::[WARN] NO SE OBTIENE ID_ALERT. REVISAR PARAMS");
      return 0;
   }


   $self->log('debug',"clear_alert::[DEBUG] COND=$condition");
   $rres=sqlSelectAll($dbh,$sel,$tab,$condition);
   if (! $rres->[0][0]) {
      $self->log('warning',"clear_alert::[WARN] NO SE OBTIENE ID_ALERT. REVISAR: $condition");
      return 0;
   }

   $table{'id_alert'}=$rres->[0][0];
   $table{'id_device'}=$rres->[0][1];
   $table{'id_alert_type'}=$rres->[0][2];
   $table{'watch'}=$rres->[0][3];
   $table{'severity'}=$rres->[0][4];
   $table{'date'}=$rres->[0][5];
   $table{'ack'}=$rres->[0][6];
   $table{'counter'}=$rres->[0][7];

   $table{'event_data'}=$rres->[0][8];
	if ($extra) { $table{'event_data'} .= " $extra";  }

   $table{'mname'}=$rres->[0][9];
   $table{'notes'}=$rres->[0][10];
   $table{'id_note_type'}=$rres->[0][11];
   $table{'type'}=$rres->[0][12];
   $table{'id_ticket'}=$rres->[0][13];
   $table{'label'}=$rres->[0][14];
   $table{'date_store'}=time;
   $table{'duration'}=$table{'date_store'}-$table{'date'};

   $table{'id_metric'}=$rres->[0][15];
   $table{'subtype'}=$rres->[0][16];

   $table{'name'}=$rres->[0][17];
   $table{'domain'}=$rres->[0][18];
   $table{'ip'}=$rres->[0][19];

   $table{'cid'}=$rres->[0][20];
   $table{'cid_ip'}=$rres->[0][21];
   $table{'cause'}=$rres->[0][22];

   $table{'date_last'}=$rres->[0][23];
   $table{'critic'}=$rres->[0][24];
   $table{'notif'}=$rres->[0][25];

	# FML No se cual es el sentido de este campo ????
   #$table{id_store}=$desc->{id_store};
   $table{'id_store'}=0;

	sqlDelete($dbh,$TAB_ALERTS_NAME,"id_alert=$table{id_alert}");
   $self->error($libSQL::err);
   $self->errorstr($libSQL::errstr);
   $self->lastcmd($libSQL::cmd);

	if ($libSQL::err) {
		#$self->log('warning',"clear_alert::[WARN]Delete->$TAB_ALERTS_NAME (ID=$table{id_alert}) ($libSQL::errstr)");
		$self->manage_db_error($dbh,"clear_alert");
		return 0;
	}

	my $rv=sqlInsert($dbh,$TAB_ALERTS_STORE_NAME,\%table);
	if (! defined $rv) {
		$self->log('warning',"clear_alert::[WARN] Insert -> $TAB_ALERTS_STORE_NAME (ID=$table{id_alert})");
	}

	return  $table{id_alert};
}


#----------------------------------------------------------------------------
# Funcion: store_cfg_monitor
# Descripcion:
# Almacena las metricas definidas por usuario
# snmp --> cfg_monitor_snmp
#----------------------------------------------------------------------------
sub store_cfg_monitor {
my ($self,$dbh,$data)=@_;
my $table_name;
my %table=();
my $rv=undef;

#| id_cfg_monitor_snmp | int(11)      |      | PRI | NULL    | auto_increment |
#| subtype             | varchar(50)  |      | MUL |         |                |
#| class               | varchar(255) | YES  |     | NULL    |                |
#| lapse               | int(11)      | YES  |     | NULL    |                |
#| descr               | varchar(255) | YES  |     | NULL    |                |
#| items               | varchar(255) | YES  |     | NULL    |                |
#| oid                 | varchar(255) | YES  |     | NULL    |                |
#| get_iid             | varchar(255) | YES  |     | NULL    |                |
#| label               | varchar(255) | YES  |     | NULL    |                |
#| vlabel              | varchar(30)  | YES  |     | NULL    |                |
#| mode                | varchar(20)  | YES  |     | NULL    |                |


   if (defined $data->{class}) {$table{class}=$data->{class};}
   if (defined $data->{lapse}) {$table{lapse}=$data->{lapse};}
   if (defined $data->{descr}) {$table{descr}=$data->{descr};}
   if (defined $data->{items}) {$table{items}=$data->{items};}
   if (defined $data->{label}) {$table{label}=$data->{label};}
   if (defined $data->{vlabel}) {$table{vlabel}=$data->{vlabel};}
   if (defined $data->{mode}) {$table{mode}=$data->{mode};}

	if ($data->{type} eq 'snmp') {
		$table_name=$TAB_CFG_MONITOR_SNMP_NAME;
		if (defined $data->{oid}) {$table{oid}=$data->{oid};}
		else {return undef;}
		if (defined $data->{get_iid}) {$table{get_iid}=$data->{get_iid};}
		my $h=md5_hex($table{oid});
		$table{subtype}= 'custom_' . substr $h,0,8;
	}
	else {return undef; }

	#Para que lo sepa la funcion llamante
	$data->{subtype}=$table{subtype};

   $rv=sqlInsert($dbh,$table_name,\%table);

   $self->error($libSQL::err);
   $self->errorstr($libSQL::errstr);
   $self->lastcmd($libSQL::cmd);

   if (defined $rv) {
      $self->log('debug',"store_cfg_monitor::[DEBUG] Insert metric $table{descr}:$table{subtype} (RV=$rv)");
      return $rv;
   }
   $rv=sqlUpdate($dbh,$table_name,\%table,"subtype=\'$table{subtype}\'");
   $self->error($libSQL::err);
   $self->errorstr($libSQL::errstr);
   $self->lastcmd($libSQL::cmd);

   if (defined $rv) {
      $self->log('debug',"store_cfg_monitor::[DEBUG] Update metric $table{descr}:$table{subtype} (RV=$rv)");
   }
   else {
      $self->log('warning',"store_cfg_monitor::[WARN] Error en Insert/Update metric $table{descr}:$table{subtype} ($libSQL::err : $libSQL::errstr)");
   }
   return $rv;
}


#----------------------------------------------------------------------------
# Funcion: store_register_app
# Descripcion:
#----------------------------------------------------------------------------
sub store_register_app {
my ($self,$dbh,$data)=@_;
my $rv=undef;
my %table=();

   if (defined $data->{name}) {$table{name}=$data->{name};}
   if (defined $data->{descr}) {$table{descr}=$data->{descr};}
   if (defined $data->{info}) {$table{info}=$data->{info};}
   if (defined $data->{type}) {$table{type}=$data->{type};}
   if (defined $data->{subtype}) {$table{subtype}=$data->{subtype};}
   if (defined $data->{cmd}) {$table{cmd}=$data->{cmd};}
   if (defined $data->{params}) {$table{params}=$data->{params};}

   $rv=sqlInsertUpdate4x($dbh,$TAB_CFG_REGISTER_APPS,\%table,\%table);
   $self->error($libSQL::err);
   $self->errorstr($libSQL::errstr);
   $self->lastcmd($libSQL::cmd);

   if ($libSQL::err) {
      #$self->log('debug',"store_register_app::[ERROR] ($libSQL::err)");
		$self->manage_db_error($dbh,"store_register_app");
      return undef;
   }


   $rv=sqlSelectAll($dbh,'id_register_app',$TAB_CFG_REGISTER_APPS,"name=\'$table{name}\'");

   $self->error($libSQL::err);
   $self->errorstr($libSQL::errstr);
   $self->lastcmd($libSQL::cmd);
   return $rv->[0][0];
}


#----------------------------------------------------------------------------
# Funcion: store_qactions
# Descripcion:
#----------------------------------------------------------------------------
sub store_qactions {
my ($self,$dbh,$data)=@_;
my $rv=undef;
my %table=();


   if (defined $data->{'descr'}) {$table{'descr'}=$data->{'descr'};}
   if (defined $data->{'action'}) {$table{'action'}=$data->{'action'};}
   if (defined $data->{'atype'}) {$table{'atype'}=$data->{'atype'};}
   if (defined $data->{'cmd'}) {$table{'cmd'}=$data->{'cmd'};}
   if (defined $data->{'params'}) {$table{'params'}=$data->{'params'};}
   if (defined $data->{'auser'}) {$table{'auser'}=$data->{'auser'};}
   if (defined $data->{'status'}) {$table{'status'}=$data->{'status'};}
	else { $table{'status'}=0; }

	$table{'date_store'}=time;
   if (defined $data->{'date_start'}) {$table{'date_start'}=$data->{'date_start'};}
   if (defined $data->{'date_end'}) {$table{'date_end'}=$data->{'date_end'};}
   if (defined $data->{'rc'}) {$table{'rc'}=$data->{'rc'};}
   if (defined $data->{'rcstr'}) {$table{'rcstr'}=$data->{'rcstr'};}

   if (defined $data->{'id_dev'}) {$table{'id_dev'}=$data->{'id_dev'};}
   if (defined $data->{'id_metric'}) {$table{'id_metric'}=$data->{'id_metric'};}

   if (defined $data->{'name'}) {$table{'name'}=$data->{'name'};}
   else {

		my $key=$table{'date_store'}.$table{'auser'}.$table{'descr'};
      my $n=md5_hex($key);
      $table{'name'}=substr $n,0,8;
   }

   $rv=sqlInsertUpdate4x($dbh,$TAB_QACTIONS,\%table,\%table);
   $self->error($libSQL::err);
   $self->errorstr($libSQL::errstr);
   $self->lastcmd($libSQL::cmd);

   if ($libSQL::err) {
      #$self->log('debug',"store_qactions::[ERROR] ($libSQL::err)");
		$self->manage_db_error($dbh,"store_qactions");
      return undef;
   }

   return $rv;
}

#----------------------------------------------------------------------------
# Funcion: log_qactions
# Descripcion:
# Almacena datos en qactions con el objetivo de registrar informacion (auditoria)
# No pretende realizar ninguna accion.
# $data es una referencia a un hash con descr,rc y rcstr
# {'descr'=> , 'rc'=>  , 'rcstr'=> }
#----------------------------------------------------------------------------
sub log_qactions {
my ($self,$dbh,$data)=@_;
my $rv=undef;

#ejemplo:
#descr: 	Login sistema
#rc:	 	OK
#rcstr: 	El usuario xxx ha hecho login correctamente desde la IP 1.1.1.1

	#$data->{'name'}=hash
	$data->{'auser'}='cnm';
	$data->{'cmd'}='';
	$data->{'params'}='';
	$data->{'action'}='info';
	my $t=time();
	$data->{'date_start'}=$t;
	$data->{'date_end'}=$t;
	$data->{'status'}=3;

	$rv=$self->store_qactions($dbh,$data);

   $self->error($libSQL::err);
   $self->errorstr($libSQL::errstr);
   $self->lastcmd($libSQL::cmd);

   if ($libSQL::err) {
      #$self->log('debug',"log_qactions::[ERROR] $libSQL::errstr (RC=$libSQL::err) (SQL=$libSQL::cmd)");
		$self->manage_db_error($dbh,"log_qactions");
      return undef;
   }

   return $rv;
}



#----------------------------------------------------------------------------
# Funcion: store_device2organizational_profile
# Descripcion:
#----------------------------------------------------------------------------
sub store_device2organizational_profile {
my ($self,$dbh,$data)=@_;
my $rv=undef;
my %table=();

   if (defined $data->{id_dev}) {$table{id_dev}=$data->{id_dev};}
   if (defined $data->{cid}) {$table{cid}=$data->{cid};}
   if (defined $data->{id_cfg_op}) {$table{id_cfg_op}=$data->{id_cfg_op};}
   elsif (defined $data->{perfil_organizativo}) {$table{id_cfg_op}=$data->{perfil_organizativo};}

   $rv=sqlInsertUpdate4x($dbh,$TAB_CFG_DEVICE2ORGANIZATIONAL_PROFILE,\%table,\%table);
   $self->error($libSQL::err);
   $self->errorstr($libSQL::errstr);
   $self->lastcmd($libSQL::cmd);

   if ($libSQL::err) {
      #$self->log('debug',"store_device2organizational_profile::[ERROR] ($libSQL::err)");
		$self->manage_db_error($dbh,"store_device2organizational_profile");
      return undef;
   }

   return $rv;
}


#----------------------------------------------------------------------------
# get_alert_type
#----------------------------------------------------------------------------
sub get_alert_type {
my ($self,$dbh,$monitor)=@_;

	if (! $monitor) { return 0; }
   my $rres=sqlSelectAll($dbh,'id_alert_type','alert_type', "monitor=\'$monitor\'");
   if (defined $rres->[0][0]) { return $rres->[0][0]; }
   else { return 0; }

}

#----------------------------------------------------------------------------
# Funcion: store_alert
# Descripcion:
# $mode=0 ==> Insert (crawler), $mode=1 ==> Update (notificationsd)
#
# Crawler/LogManager 	-> mode=1
# 
# Notifications (mail) 	-> mode=1
# 
# SET+is_post 		-> mode=2
# SET					-> mode=1
# PASS				-> mode=0
# default			-> mode=1
# 
# syslog_manager	-> mode=1
# log2db				-> mode=1
#----------------------------------------------------------------------------
sub store_alert {
my ($self,$dbh,$monitor,$data,$mode)=@_;
my %table=();
my $rv=undef;
my $id_device=undef;
my $rres;

   $self->error(0);
   $self->errorstr('OK');
   $self->response('');

	# $table{id_device} ----------------------------------
	if (defined $data->{id_dev}) { $data->{id_device}=$data->{id_dev}; }

   if (! defined $data->{id_device}) {
		# Busco el id_device (select por ip) -------------
		# select id_dev from devices where ip='10.217.203.254';

		my $rres=sqlSelectAll($dbh,'id_dev',$TAB_DEVICES_NAME, "ip=\'$data->{ip}\'");
		$table{id_device}=$rres->[0][0];
		if (!defined $table{id_device}) {
			my $ip = (defined $data->{ip}) ? $data->{ip} : 'undef';
			$self->log('warning',"store_alert::[WARN] Error IP=$ip (id_dev=undef)");
			return (undef,undef,undef);
		}
	}
	else {$table{id_device} = $data->{id_device}; }

   # $table{ip} ----------------------------------
   if (defined $data->{ip}) { $table{ip}=$data->{ip}; }
   # $table{name} ----------------------------------
   if (defined $data->{name}) { $table{name}=$data->{name}; }
   # $table{domain} ----------------------------------
   if (defined $data->{domain}) { $table{domain}=$data->{domain}; }
   # $table{critic} ----------------------------------
   if (defined $data->{critic}) { $table{critic}=$data->{critic}; }
   # $table{notif} ----------------------------------
   if (defined $data->{notif}) { $table{notif}=$data->{notif}; }

	# $table{date_last} ----------------------------------
   if (defined $data->{date_last}) { $table{date_last}=$data->{date_last}; }

   #if (! defined $monitor) {
	#	$self->log('warning',"store_alert::[WARN] monitor=UNDEF");
	#	return;
	#}
	
   # $table{id_alert_type} ----------------------------------
   if (! defined $data->{id_alert_type}) {
		if (! $monitor) { $table{id_alert_type} = 0; }
		else {

			$table{id_alert_type} = $self->get_alert_type($dbh,$monitor);

#	      $rres=sqlSelectAll($dbh,'id_alert_type',$TAB_ALERT_TYPE_NAME, "monitor=\'$monitor\'");
#   	   if (defined $rres->[0][0]) { $table{id_alert_type} = $rres->[0][0]; }
#      	else {
#				# En este cso no se trata de un monitor sino de una metrica
#         	$table{id_alert_type} = 0;
#         	#$self->log('warning',"store_alert::[WARN***] ID_ALERT_TYPE=DESC monitor=\'$monitor\' ($libSQL::err)");
#			}
      }
   }
	else { $table{id_alert_type} = $data->{id_alert_type}; }

   if (! defined $data->{mname}) {
      $self->log('warning',"store_alert::[WARN] mname=UNDEF");
      return (undef,undef,undef);
   }
	else { $table{mname} = $data->{mname}; }

   # $table{subtype} ----------------------------------
   if (defined $data->{subtype}) { $table{subtype} = $data->{subtype}; }

   # $table{severity} ----------------------------------
   $table{severity} = (defined $data->{severity}) ? $data->{severity} : 1;

   # $table{mode} --------------------------------
   if (exists $data->{mode})  { $table{mode} = $data->{mode}; }
	else { $table{mode} = '0'; }

	# $table{counter} ----------------------------------
	# Si en los datos de entrada se especifica counter, se utiliza el valor especificado.
	# En caso contrario (lo normal) se incrementa el valor almacenado, salvo la primera vez
	# (todavia no exoste la alerta en BBDD) que se inicializa a -1+1 o a -5+1
	if (! defined $data->{counter}) {
	 	my $where="id_device=\'$table{id_device}\' and mname=\'$table{mname}\'";
      if (exists $table{mode}) { $where.=" and mode=\'$table{mode}\'";}
		$rres=sqlSelectAll($dbh,'counter', $TAB_ALERTS_NAME, $where);

#my $err=$libSQL::err;
#my $errorstr=$libSQL::errstr;
#my $cmd=$libSQL::cmd;
#$self->log('warning',"store_alert::**FML** SELECT COUNTER  ERR=$err ERRSTR=$errorstr CMD=$cmd");

		my $dev_wsize=0;
		if ((exists $data->{wsize}) && ($data->{wsize}=~/\d+/)) { $dev_wsize=$data->{wsize}; }
      my $init_value = ($table{severity} == 4) ? -5 : -$dev_wsize;

      $table{counter} = (defined $rres->[0][0]) ? $rres->[0][0] : $init_value;

#$self->log('info',"store_alert::[**FMLL**] INITV=$init_value counter=$table{counter} SEV=$table{severity} COND=$where");


		$table{counter}++;
	}
	else { $table{counter} = $data->{counter}; }		

	# $table{date} --------------------------------------
	if ($table{counter} == 1)  { $table{date}=time; }

	# $table{watch} ----------------------------------
	#$table{watch} = (defined $data->{watch}) ? $data->{watch} : '0';
	$table{watch} = $monitor;
	
   # $table{event_data} --------------------------------
	$table{event_data} = (defined $data->{event_data}) ? $data->{event_data} : undef;

   # $table{mname} --------------------------------
   $table{mname} = $data->{mname};

   # $table{type} --------------------------------
   $table{type} = $data->{type};

   # $table{id_ticket} --------------------------------
   #$table{id_ticket} = $data->{id_ticket};

	#id_ticket solo debe ser manejado por el GUI
	#$table{id_ticket} = (defined $data->{id_ticket}) ? $data->{id_ticket} : '0';

   # $table{label} --------------------------------
   #$table{label} = $data->{label};

   # $table{cause} --------------------------------
   $table{cause} = $data->{cause};
   $table{label} = $data->{cause};

   # $table{id_metric} --------------------------------
   if (exists $data->{id_metric})  { $table{id_metric} = $data->{id_metric}; }

   # $table{correlated} ----------------------------------
   $table{correlated} = (defined $data->{correlated}) ? $data->{correlated} : '';
  
   # $table{hidx} --------------------------------------
   #$table{hidx} = (defined $data->{hidx}) ? $data->{hidx} : 1;
	my $cid=$self->cid() || 'unknown';
	my $cid_ip=$self->cid_ip() || '';
   $table{cid} = (defined $data->{cid}) ? $data->{cid} : $cid;
   $table{cid_ip} = (defined $data->{cid_ip}) ? $data->{cid_ip} : $cid_ip;


	#----------------------------------------------------
	#fml my $where="id_device=\'$table{id_device}\' and id_alert_type=\'$table{id_alert_type}\'";
   my $where="id_device=\'$table{id_device}\' and mname=\'$table{mname}\'";
   if (exists $table{mode}) { $where.=" and mode=\'$table{mode}\'";}

	my $what='id_alert,date';


	#-----------------------------------------------------
	# MODO INSERT
	# Si ya existe no se inserta.
	# Si no existe se inserta con counter=0.
	# Sirve para almacenar en BBDD una alerta cuya ventana no se ha cumplido.
	# Es el proceso de alertas el que se encargara de incrementar el counter.
	#-----------------------------------------------------
	if ($mode==0) {

  	 	#Ejecuto el insert con noerr=1
		$table{counter} = 0;

   	my $rv=sqlInsert($dbh,$TAB_ALERTS_NAME,\%table,1);

##my $err=$libSQL::err;
##my $errorstr=$libSQL::errstr;
##my $cmd=$libSQL::cmd;
##$self->log('warning',"store_alert::**FML** INSERT ERR=$err ERRSTR=$errorstr CMD=$cmd");

		if ($libSQL::err == 0) {
	     	my $rres=sqlSelectAll($dbh,$what,$TAB_ALERTS_NAME,$where);
      	return ($rres->[0][0],$rres->[0][1],$table{counter});
   	}
      else {
         my $err=$libSQL::err;
         my $errorstr=$libSQL::errstr;
         my $cmd=$libSQL::cmd;
         $self->log('warning',"store_alert::**DBERROR** INSERT ($mode) ERR=$err ERRSTR=$errorstr CMD=$cmd");
      }
	}

   #-----------------------------------------------------
   # MODO UPDATE
   # Se hace un update. Si no hay ninguna fila afectada,
   # se hace un insert
   #-----------------------------------------------------
	elsif ($mode==1) {

      $rv=sqlUpdate($dbh,$TAB_ALERTS_NAME,\%table,$where);

		#Si el update ha afectado alguna fila
		if (($rv=~/\d+/) && ($rv>0)) {
			$self->response('update');
         my $rres=sqlSelectAll($dbh,$what,$TAB_ALERTS_NAME,$where);
         return ($rres->[0][0],$rres->[0][1],$table{counter});
      }
		#Si el update no ha afectado ninguna fila (posibemente no existiera la fila)
		#hago un insert
		elsif ($rv eq "0E0") {


# Creo que sobra. Se hace mas arriba.
#      	$table{counter} = ($table{severity} == 4) ? -4 : 1;



#
##fml
#if (($table{'mname'} eq 'mon_icmp') && ($table{'ip'} eq '10.2.254.71')) {
#$table{'counter'}=-10;
#$self->log('warning',"store_alert::**FML** COUNTER=-10");
##$self->log('info',"get_current_alerts:: mon_icmp GET $key **FML** IP=$calert->{'ip'}");
#}




			my $rv=sqlInsert($dbh,$TAB_ALERTS_NAME,\%table,0);

	      if (($rv=~/\d+/) && ($rv>0)) {
				$self->response('insert');
   	      my $rres=sqlSelectAll($dbh,$what,$TAB_ALERTS_NAME,$where);
      	   return ($rres->[0][0],$rres->[0][1],$table{counter});
      	}
			else {
	         my $err=$libSQL::err;
   	      my $errorstr=$libSQL::errstr;
      	   my $cmd=$libSQL::cmd;
				$self->log('warning',"store_alert::**FML DEBUG** UPDATE ($mode) RV=$rv ERR=$err ERRSTR=$errorstr CMD=$cmd");
			}
		}
		# Si se ha producido un error	
		else {
			my $err=$libSQL::err;
			my $errorstr=$libSQL::errstr;
			my $cmd=$libSQL::cmd;
			$self->log('warning',"store_alert::**DBERROR** UPDATE ($mode) ERR=$err ERRSTR=$errorstr CMD=$cmd");
		}
	}

   #-----------------------------------------------------
	# Alertas de analisis
   #-----------------------------------------------------
   elsif ($mode==2) {
		
		if ($table{counter} == 0) { $table{counter} = 1; }

   	if (defined $data->{event_data}) {
      	$rres=sqlSelectAll($dbh,'event_data', $TAB_ALERTS_NAME, "id_device=\'$table{id_device}\' and mname=\'$table{mname}\'");
			$table{event_data}= $rres->[0][0] . $data->{event_data};
   	}

     	$rv=sqlInsertUpdate4x($dbh,$TAB_ALERTS_NAME,\%table,\%table);

      if (defined $rv) {
         my $rres=sqlSelectAll($dbh,$what,$TAB_ALERTS_NAME,$where);
         return ($rres->[0][0],$rres->[0][1],$table{counter});
      }
   }

   $self->log('warning',"store_alert::[WARN] Error en Insert/Update alert MODE=$mode ID_DEV=$table{id_device} (RV=undef)");
	return (undef,undef,undef);

}




#----------------------------------------------------------------------------
# store_alerts_summary
#----------------------------------------------------------------------------
#
# Almacena en alerts_summary la consolidacion de las alertas
#
#----------------------------------------------------------------------------
sub store_alerts_summary  {
my ($self,$dbh)=@_;

	my $rres;
   my ($what, $from, $where, $other) = ('', '', '', '');
	my %SUMMARY=();

   #-----------------------------------------------
	#Perfiles Organizativos
   #-----------------------------------------------
	#select distinct id_cfg_op from  cfg_organizational_profile;

  	$what = 'distinct id_cfg_op';
   $from = 'cfg_organizational_profile';
   $where = '';
   $rres=sqlSelectAll($dbh, $what, $from, $where, $other);
	foreach my $v (@$rres) {
		my $id = $v->[0];
		$SUMMARY{$id}={ 'events'=> 0, 'notices'=>0, 'devices'=>0, 'red_devices'=>0, 'orange_devices'=>0, 'yellow_devices'=>0, 'blue_devices'=>0, };
	}


   #-----------------------------------------------
	# Eventos
   #-----------------------------------------------
#	SELECT o.id_cfg_op,count(DISTINCT e.id_event) as cuantos
#   FROM events e,devices d,cfg_devices2organizational_profile o
#	WHERE e.ip=d.ip and d.id_dev=o.id_dev group by o.id_cfg_op ;

	$what = 'o.id_cfg_op,count(DISTINCT e.id_event) as cuantos';
	$from = 'events e,devices d,cfg_devices2organizational_profile o';

$what = 'count(*) as cuantos';
$from = 'events';


#	$where = 'e.ip=d.ip and d.id_dev=o.id_dev group by o.id_cfg_op';
   $rres=sqlSelectAll($dbh, $what, $from, $where, $other);

#  $self->error($libSQL::err);
#   $self->errorstr($libSQL::errstr);
#   $self->lastcmd($libSQL::cmd);
my $EVENTS=0;
   foreach my $v (@$rres) {
      #my $id = $v->[0];
		#my $events = $v->[1];
		#my $events = $v->[0];
      #$SUMMARY{$id}->{'events'} = $events;
      $EVENTS = $v->[0];
   }


   #-----------------------------------------------
   # Avisos
   #-----------------------------------------------
   $what = 'o.id_cfg_op,count(DISTINCT n.id_notif) as cuantos';
   $from = 'notifications n, cfg_notifications c,alert_type a, devices d,notification_type t, cfg_devices2organizational_profile o';
   $where = 'n.id_cfg_notification=c.id_cfg_notification and a.monitor=c.monitor and n.id_dev=d.id_dev and c.id_notification_type=t.id_notification_type and n.id_dev=o.id_dev group by o.id_cfg_op';
   $rres=sqlSelectAll($dbh, $what, $from, $where, $other);

   foreach my $v (@$rres) {
      my $id = $v->[0];
      my $notices = $v->[1];
      $SUMMARY{$id}->{'notices'} = $notices;
   }

   $what = 'o.id_cfg_op,count(DISTINCT n.id_notif) as cuantos';
   $from = 'notifications n, cfg_notifications c,cfg_monitor a, devices d,notification_type t , cfg_devices2organizational_profile o';
   $where = 'n.id_cfg_notification=c.id_cfg_notification and a.monitor=c.monitor and n.id_dev=d.id_dev and c.id_notification_type=t.id_notification_type and n.id_dev=o.id_dev group by o.id_cfg_op';
   $rres=sqlSelectAll($dbh, $what, $from, $where, $other);

   foreach my $v (@$rres) {
      my $id = $v->[0];
      my $notices = $v->[1];
      $SUMMARY{$id}->{'notices'} += $notices;
   }

   $what = 'o.id_cfg_op,count(DISTINCT n.id_notif) as cuantos';
   $from = 'notifications n, cfg_notifications c,cfg_remote_alerts a, devices d,notification_type t , cfg_devices2organizational_profile o';
   $where = 'n.id_cfg_notification=c.id_cfg_notification and a.subtype=c.monitor and n.id_dev=d.id_dev and c.id_notification_type=t.id_notification_type and n.id_dev=o.id_dev group by o.id_cfg_op';
   $rres=sqlSelectAll($dbh, $what, $from, $where, $other);

   foreach my $v (@$rres) {
      my $id = $v->[0];
      my $notices = $v->[1];
      $SUMMARY{$id}->{'notices'} += $notices;
   }


   #-----------------------------------------------
   # Dispositivos - blue
   #-----------------------------------------------
   $what = 'o.id_cfg_op,count(distinct a.id_device) as cuantos';
   $from = 'alerts a, cfg_devices2organizational_profile o';
   $where = 'counter>0 AND a.id_device=o.id_dev AND a.severity!=4 group by o.id_cfg_op';
   $rres=sqlSelectAll($dbh, $what, $from, $where, $other);

   foreach my $v (@$rres) {
      my $id = $v->[0];
      my $devices = $v->[1];
      $SUMMARY{$id}->{'devices'} = $devices;
   }

   #-----------------------------------------------
	# red_devices
   $where = 'counter>0 AND a.id_device=o.id_dev AND a.severity=1 group by o.id_cfg_op';
   $rres=sqlSelectAll($dbh, $what, $from, $where, $other);
   foreach my $v (@$rres) {
      my $id = $v->[0];
      my $devices = $v->[1];
      $SUMMARY{$id}->{'red_devices'} = $devices;
   }

   #-----------------------------------------------
   # orange_devices
   $where = 'counter>0 AND a.id_device=o.id_dev AND a.severity=2 group by o.id_cfg_op';
   $rres=sqlSelectAll($dbh, $what, $from, $where, $other);
   foreach my $v (@$rres) {
      my $id = $v->[0];
      my $devices = $v->[1];
      $SUMMARY{$id}->{'orange_devices'} = $devices;
   }

   #-----------------------------------------------
   # yellow_devices
   $where = 'counter>0 AND a.id_device=o.id_dev AND a.severity=3 group by o.id_cfg_op';
   $rres=sqlSelectAll($dbh, $what, $from, $where, $other);
   foreach my $v (@$rres) {
      my $id = $v->[0];
      my $devices = $v->[1];
      $SUMMARY{$id}->{'yellow_devices'} = $devices;
   }

   #-----------------------------------------------
   # blue_devices
   $where = 'counter>0 AND a.id_device=o.id_dev AND a.severity=4 group by o.id_cfg_op';
   $rres=sqlSelectAll($dbh, $what, $from, $where, $other);
   foreach my $v (@$rres) {
      my $id = $v->[0];
      my $devices = $v->[1];
      $SUMMARY{$id}->{'blue_devices'} = $devices;
   }




   #-----------------------------------------------
   # Alertas por severidad
   #-----------------------------------------------
   $what = 'a.severity,count(DISTINCT a.id_alert) as cuantos';
   $from = 'alerts a,devices d, cfg_devices2organizational_profile o';
   $where = 'd.id_dev=a.id_device and a.counter>0 AND d.id_dev=o.id_dev AND o.id_cfg_op in (_ID_) group by a.severity order by a.severity';

	foreach my $id (keys %SUMMARY) {

		$SUMMARY{$id}->{'red_alerts'} = 0;	
		$SUMMARY{$id}->{'orange_alerts'} = 0;	
		$SUMMARY{$id}->{'yellow_alerts'} = 0;	
		$SUMMARY{$id}->{'blue_alerts'} = 0;	
		$SUMMARY{$id}->{'grey_alerts'} = 0;	
		$SUMMARY{$id}->{'events'} = $EVENTS;
		my $where_id=$where;
		$where_id =~ s/_ID_/$id/;
   	$rres=sqlSelectAll($dbh, $what, $from, $where_id, $other);
		foreach my $v (@$rres) {
			my $severity=$v->[0];
			my $cnt=$v->[1];

			if ($severity == 1) { $SUMMARY{$id}->{'red_alerts'} = $cnt; }
			elsif ($severity == 2) { $SUMMARY{$id}->{'orange_alerts'} = $cnt; }
			elsif ($severity == 3) { $SUMMARY{$id}->{'yellow_alerts'} = $cnt; }
			elsif ($severity == 4) { $SUMMARY{$id}->{'blue_alerts'} = $cnt; }
			elsif ($severity == 5) { $SUMMARY{$id}->{'grey_alerts'} = $cnt; }

			$SUMMARY{$id}->{'events'} = $EVENTS;
		}
	}

   foreach my $id (keys %SUMMARY) {

      $SUMMARY{$id}->{'id_cfg_op'}=$id;
      my $rv=sqlInsertUpdate4x($dbh,'alerts_summary_op',$SUMMARY{$id},$SUMMARY{$id});
   }


	%SUMMARY=();	# Indexado por id_user
	my %VIEWS=(); 	# Hash de vistas en alerta, key=id_view value=severity

   #-----------------------------------------------
   # Usuarios Definidos
   #-----------------------------------------------
   #select distinct id_user from  cfg_users;

   $what = 'distinct id_user';
   $from = 'cfg_users';
   $where = '';
   $rres=sqlSelectAll($dbh, $what, $from, $where, $other);
   foreach my $v (@$rres) {
      my $id = $v->[0];
      $SUMMARY{$id}={ 'red_views'=> 0, 'orange_views'=>0, 'yellow_views'=>0, 'blue_views'=>0, 'grey_views'=>0 };
   }

   #-----------------------------------------------
   # Vistas por severidad
   #-----------------------------------------------
	sqlDrop($dbh,'tv');
	my $fields = 'select m.id_metric,a.severity from alerts a, metrics m where a.id_device=m.id_dev and a.mname=m.name and a.counter>1';
	my $rv = sqlCreate($dbh,'tv',$fields,1);

   $what = 'distinct c.id_cfg_view,t.severity';
   $from = 'cfg_views2metrics c, cfg_user2view u, tv t';
   $where = 'c.id_metric=t.id_metric and u.id_cfg_view=c.id_cfg_view and u.id_user=_ID_';
	my ($red, $orange, $yellow) = (0,0,0);
	%VIEWS=();

   foreach my $id_user (keys %SUMMARY) {

		$SUMMARY{$id_user}->{'red_views'} = 0;
		$SUMMARY{$id_user}->{'orange_views'} = 0;
		$SUMMARY{$id_user}->{'yellow_views'} = 0;
		$SUMMARY{$id_user}->{'blue_views'} = 0;
		$SUMMARY{$id_user}->{'grey_views'} = 0;
		if ($id_user == 1) { $rres=sqlSelectAll($dbh, $what, 'cfg_views2metrics c, tv t', 'c.id_metric=t.id_metric', $other);  }
		else {
	      my $where_id=$where;
   	   $where_id =~ s/_ID_/$id_user/;
      	$rres=sqlSelectAll($dbh, $what, $from, $where_id, $other);
		}

      foreach my $v (@$rres) {
         my $id_view=$v->[0];
			my $severity=$v->[1];
			if ( exists $VIEWS{$id_view} ) {
				if ( $VIEWS{$id_view} > $severity) { $VIEWS{$id_view}=$severity; }
			}
			else { $VIEWS{$id_view}=$severity; }
      }
   }

   $what = 'id_device';
   $from = 'alerts a, metrics m';
   $where = "a.id_device = m.id_dev and m.name=a.mname and counter>1 and (mname='mon_snmp' or mname='mon_wbem' or  name like '%_icmp' )";
	$rres=sqlSelectAll($dbh, $what, $from, $where, $other);
	my @aux=();
	foreach my $v (@$rres) { push @aux, $v->[0]; }
	my $dev_list=join (',',@aux);
	my $metric_list;
	if ( scalar(@aux) == 0) { $metric_list=0; }
	else {

	   $what = 'id_metric';
   	$from = 'metrics';
   	$where = "name like '%_icmp' and id_dev in ($dev_list)";
		$rres=sqlSelectAll($dbh, $what, $from, $where, $other);
		@aux=();
		foreach my $v (@$rres) { push @aux, $v->[0]; }
		$metric_list=join (',',@aux);
		if ( scalar(@aux) == 0) { $metric_list=0; }
	}

	$what = 'distinct c.id_cfg_view';
	$from = 'cfg_views2metrics c, cfg_user2view u';
	$where = "u.id_cfg_view=c.id_cfg_view and u.id_user=_ID_ and id_metric in ($metric_list)";

   foreach my $id_user (keys %SUMMARY) {

      if ($id_user == 1) { $rres=sqlSelectAll($dbh, 'distinct c.id_cfg_view', 'cfg_views2metrics c',"id_metric in ($metric_list)", $other);  }
      else {
         my $where_id=$where;
         $where_id =~ s/_ID_/$id_user/;
         $rres=sqlSelectAll($dbh, $what, $from, $where_id, $other);
      }
		#%VIEWS=();
      foreach my $v (@$rres) {
         my $id_view=$v->[0];
			$VIEWS{$id_view} = 1;  # Severidad roja
      }
   }

   foreach my $id_user (keys %SUMMARY) {
      foreach my $id_view (keys %VIEWS) {

         if ($VIEWS{$id_view} == 1) { $SUMMARY{$id_user}->{'red_views'} += 1;  }
         elsif ($VIEWS{$id_view} == 2) { $SUMMARY{$id_user}->{'orange_views'} += 1;  }
         elsif ($VIEWS{$id_view} == 3) { $SUMMARY{$id_user}->{'yellow_views'} += 1;  }
         elsif ($VIEWS{$id_view} == 4) { $SUMMARY{$id_user}->{'blue_views'} += 1;  }
         elsif ($VIEWS{$id_view} == 5) { $SUMMARY{$id_user}->{'grey_views'} += 1;  }
      }
   }

   foreach my $id_user (keys %SUMMARY) {

      $SUMMARY{$id_user}->{'id_user'}=$id_user;
      my $rv=sqlInsertUpdate4x($dbh,'alerts_summary_user',$SUMMARY{$id_user},$SUMMARY{$id_user});
   }
}

#----------------------------------------------------------------------------
# store_alerts_read
#----------------------------------------------------------------------------
#
# Consolida en alerts_read la informacion de alertas locales y remotas para las consultas 
# en cliente
#
#----------------------------------------------------------------------------
sub store_alerts_read  {
my ($self,$dbh)=@_;

	my $cid=$self->cid();
	my $cid_ip=$self->cid_ip();
	my $rv=sqlCmd($dbh,"CALL sp_alerts_read(\'$cid\',\'$cid_ip\')");

   $self->error($libSQL::err);
   $self->errorstr($libSQL::errstr);
   $self->lastcmd($libSQL::cmd);
	if ($libSQL::err) {
		#$self->log('info',"store_alerts_read::**ERR** RES=$libSQL::err ($libSQL::errstr)");
		$self->manage_db_error($dbh,"store_alerts_read");
	}
}

#----------------------------------------------------------------------------
# sp_alerts_read_local_set
#----------------------------------------------------------------------------
#
# Genera una alerta (SET) en alerts_read.
# Se usa para insertar los datos de la alerta local generada por un evento
# (trap, syslog, email ....) sin necesidad de regenerar alerts_read
#
#----------------------------------------------------------------------------
sub store_alerts_read_local_set  {
my ($self,$dbh,$id_alert)=@_;

   my $cid=$self->cid();
   my $cid_ip=$self->cid_ip();
   my $rv=sqlCmd($dbh,"CALL sp_alerts_read_local_set(\'$cid\',\'$cid_ip\',$id_alert)");

   $self->error($libSQL::err);
   $self->errorstr($libSQL::errstr);
   $self->lastcmd($libSQL::cmd);
   if ($libSQL::err) {
      $self->manage_db_error($dbh,"store_alerts_read_local_set");
   }
}

#----------------------------------------------------------------------------
# sp_alerts_read_local_clr
#----------------------------------------------------------------------------
#
# Elimina una alerta (CLR) de alerts_read.
# Se usa para borrar los datos de la alerta local generada por un evento
# (trap, syslog, email ....) sin necesidad de regenerar alerts_read
#
#----------------------------------------------------------------------------
sub store_alerts_read_local_clr  {
my ($self,$dbh,$id_alert)=@_;

   my $cid=$self->cid();
   my $cid_ip=$self->cid_ip();
   my $rv=sqlCmd($dbh,"CALL sp_alerts_read_local_clr(\'$cid\',\'$cid_ip\',$id_alert)");

   $self->error($libSQL::err);
   $self->errorstr($libSQL::errstr);
   $self->lastcmd($libSQL::cmd);
   if ($libSQL::err) {
      $self->manage_db_error($dbh,"store_alerts_read_local_clr");
   }
}



#----------------------------------------------------------------------------
# store_alert_cleared
#----------------------------------------------------------------------------
#| id_alert      | int(11)      | NO   | PRI | NULL    | auto_increment |
#| id_device     | int(11)      | NO   |     | 0       |                |
#| id_alert_type | int(11)      | NO   |     | 0       |                |
#| cause         | varchar(255) | NO   |     |         |                |
#| name          | varchar(50)  | NO   |     |         |                |
#| domain        | varchar(30)  | NO   |     |         |                |
#| ip            | varchar(22)  | NO   |     |         |                |
#| notif         | int(11)      | YES  |     | 0       |                |
#| mname         | varchar(255) | NO   |     |         |                |
#| watch         | varchar(255) | YES  |     | 0       |                |
#
#----------------------------------------------------------------------------
#sub store_alert_cleared {
sub store_notif_alert {
my ($self,$dbh,$type,$data)=@_;

   $self->error(0);
   $self->errorstr('OK');

	my %table=();
   if (defined $data->{'id_alert'}) { $table{'id_alert'}=$data->{'id_alert'}; }
   if (defined $data->{'id_device'}) { $table{'id_device'}=$data->{'id_device'}; }
   if (defined $data->{'id_alert_type'}) { $table{'id_alert_type'}=$data->{'id_alert_type'}; }
   if (defined $data->{'cause'}) { $table{'cause'}=$data->{'cause'}; }
   if (defined $data->{'name'}) { $table{'name'}=$data->{'name'}; }
   if (defined $data->{'domain'}) { $table{'domain'}=$data->{'domain'}; }
   if (defined $data->{'ip'}) { $table{'ip'}=$data->{'ip'}; }
   if (defined $data->{'notif'}) { $table{'notif'}=$data->{'notif'}; }
   if (defined $data->{'mname'}) { $table{'mname'}=$data->{'mname'}; }
   if (defined $data->{'watch'}) { $table{'watch'}=$data->{'watch'}; }
   if (defined $data->{'event_data'}) { $table{'event_data'}=$data->{'event_data'}; }
   if (defined $data->{'ack'}) { $table{'ack'}=$data->{'ack'}; }
   if (defined $data->{'id_ticket'}) { $table{'id_ticket'}=$data->{'id_ticket'}; }
   if (defined $data->{'severity'}) { $table{'severity'}=$data->{'severity'}; }
   if (defined $data->{'type'}) { $table{'type'}=$data->{'type'}; }
   if (defined $data->{'date'}) { $table{'date'}=$data->{'date'}; }
   if (defined $data->{'counter'}) { $table{'counter'}=$data->{'counter'}; }
   if (defined $data->{'id_metric'}) { $table{'id_metric'}=$data->{'id_metric'}; }

	my $table_name = 'notif_alerts_set';
	if ($type eq 'clr') { $table_name = 'notif_alerts_clear'; }
   my $rv=sqlInsert($dbh,$table_name,\%table,0);

   $self->error($libSQL::err);
   $self->errorstr($libSQL::errstr);
   $self->lastcmd($libSQL::cmd);
   if ($libSQL::err) {
      $self->manage_db_error($dbh,"store_notif_alert");
   }

}

#----------------------------------------------------------------------------
sub get_notif_alerts_set {
my ($self,$dbh)=@_;

   my $rres=sqlSelectAll($dbh, 'n.id_device,n.id_alert_type,n.cause,n.name,n.domain,n.ip,a.notif,n.id_alert,n.mname,n.watch,n.event_data,n.ack,n.id_ticket,n.severity,n.type,n.date,n.counter,n.id_metric', 'notif_alerts_set n , alerts a', 'n.id_alert=a.id_alert', '');

   $self->error($libSQL::err);
   $self->errorstr($libSQL::errstr);
   $self->lastcmd($libSQL::cmd);
   if ($libSQL::err) {
      $self->manage_db_error($dbh,"get_notif_alerts_set");
   }
	else {
		sqlDelete($dbh,'notif_alerts_set','');
	}
	return $rres;
}

#----------------------------------------------------------------------------
sub get_notif_alerts_clear {
my ($self,$dbh)=@_;

   my $rres=sqlSelectAll($dbh, 'id_device,id_alert_type,cause,name,domain,ip,notif,id_alert,mname,watch,event_data,ack,id_ticket,severity,type,date,counter,id_metric', 'notif_alerts_clear', '', '');

   $self->error($libSQL::err);
   $self->errorstr($libSQL::errstr);
   $self->lastcmd($libSQL::cmd);
   if ($libSQL::err) {
      $self->manage_db_error($dbh,"get_notif_alerts_clear");
   }
   else {
      sqlDelete($dbh,'notif_alerts_clear','');
   }
   return $rres;
}



#----------------------------------------------------------------------------
# get_inside_correlation_rules
# Obtiene las reglas de correlacion interna definidas
#+--------------+--------------------------------------------------------------------------------------------------------------------+------------------------------------------------------------+
#| rule_subtype | rule_expr                                                                                                          | rule_descr                                                 |
#+--------------+--------------------------------------------------------------------------------------------------------------------+------------------------------------------------------------+
#| 00000000     | [{"orig":"","dest":""}]                                                                                            | REGLAS BÁSICAS                                             |
#| 00000001     | [{"orig":{"subtype":["mon_icmp"]},"dest":{"type":["latency"]}}]                                                    | NO PING => NO TCP/IP                                       |
#| 00000002     | [{"orig":{"subtype":["mon_icmp"]},"dest":{"type":["latency","snmp","xagent"]}}]                                    | NO PING => NO TCP/IP, NO SNMP, NO XAGENT                   |
#| 00000003     | [{"orig":{"subtype":["mon_icmp"]},"dest":{"type":["latency","snmp","xagent","snmp-trap","syslog","email","api"]}}] | NO PING => NO TCP/IP, NO SNMP, NO XAGENT, NO ALERTA REMOTA |
#+--------------+--------------------------------------------------------------------------------------------------------------------+------------------------------------------------------------+
#
#----------------------------------------------------------------------------
sub get_inside_correlation_rules {
my ($self,$dbh)=@_;


   my $rres=sqlSelectAll(  $dbh, 'rule_subtype,rule_expr', 'cfg_inside_correlation_rules', '', '' );

   my %config=();
	eval {
	   foreach my $v (@$rres) {
			$config{$v->[0]} = decode_json($v->[1]);
   	}	
	};
	if ($@) {
		$self->log('warning',"get_inside_correlation_rules::[WARN] ERROR EN RULE ($@)");		
	}
	return \%config;
}

#----------------------------------------------------------------------------
# get_cnm_services_info
# Obtiene los datos locales para poder validar la subscripcion (rev,cfgkey)
#----------------------------------------------------------------------------
sub get_cnm_services_info {
my ($self,$dbh)=@_;


   my $rres=sqlSelectAll(  $dbh, 'type,value', 'cnm_services', '', '' );

	my %config=();
   foreach my $v (@$rres) {   
		#if ($v->[0] eq 'rev' ) { $config{'rev'}=$v->[1]; }
		if ($v->[0] eq 'cfgkey' ) { $config{'key'}=$v->[1]; }
		elsif ($v->[0] eq 'support' ) { $config{'support'}=$v->[1]; }
		elsif ($v->[0] eq 'hid' ) { $config{'hid'}=$v->[1]; }
	}

	$config{'rev'}=`cd /opt/cnm ; /usr/bin/git describe --tags`;
	chomp $config{'rev'};

	$config{'num_app'}=sqlSelectCount($dbh,'devices','status !=3');
   return \%config;
}

#----------------------------------------------------------------------------
# store_cnm_services_info
# Almacena los servicios subscritos en local (num, tlast)
#----------------------------------------------------------------------------
sub store_cnm_services_info {
my ($self,$dbh,$info)=@_;

	
	my %data=('type'=>0, 'value'=>0, 'date_store'=>0);
	$data{'date_store'} = time();

   #------------------------------------------------------------------------
	if ((exists $info->{'tlast'}) && ($info->{'tlast'}=~/\d+/)) { 
		$data{'type'} = 'tlast';
		$data{'value'} = $info->{'tlast'};

	   my $rv=sqlInsertUpdate4x($dbh,'cnm_services',\%data,\%data);
   	$self->error($libSQL::err);
   	$self->errorstr($libSQL::errstr);
   	$self->lastcmd($libSQL::cmd);

   	if ($libSQL::err) {
      	$self->manage_db_error($dbh,"store_cnm_services_info");
      	return undef;
   	}
	}

	#------------------------------------------------------------------------
	if ((exists $info->{'num'}) && ($info->{'num'}=~/\d+/)) {
      $data{'type'} = 'num';
      $data{'value'} = $info->{'num'};

      my $rv=sqlInsertUpdate4x($dbh,'cnm_services',\%data,\%data);
      $self->error($libSQL::err);
      $self->errorstr($libSQL::errstr);
      $self->lastcmd($libSQL::cmd);

      if ($libSQL::err) {
         $self->manage_db_error($dbh,"store_cnm_services_info");
         return undef;
      }
   }

   #------------------------------------------------------------------------
   if ((exists $info->{'support'}) && ($info->{'support'}=~/\w+/)) {
      $data{'type'} = 'support';
      $data{'value'} = $info->{'support'};

      my $rv=sqlInsertUpdate4x($dbh,'cnm_services',\%data,\%data);
      $self->error($libSQL::err);
      $self->errorstr($libSQL::errstr);
      $self->lastcmd($libSQL::cmd);

      if ($libSQL::err) {
         $self->manage_db_error($dbh,"store_cnm_services_info");
         return undef;
      }
   }

	#------------------------------------------------------------------------
	$data{'type'} = 'rev';
	$data{'value'}=`cd /opt/cnm ; /usr/bin/git describe --tags`;
   chomp $data{'value'};

   my $rv=sqlInsertUpdate4x($dbh,'cnm_services',\%data,\%data);
   $self->error($libSQL::err);
   $self->errorstr($libSQL::errstr);
   $self->lastcmd($libSQL::cmd);

   if ($libSQL::err) {
      $self->manage_db_error($dbh,"store_cnm_services_info");
      return undef;
   }


   return;
}

#----------------------------------------------------------------------------
# store_cnm_services_hid
# Almacena el valor del hid local
#----------------------------------------------------------------------------
sub store_cnm_services_hid {
my ($self,$dbh,$value)=@_;

	my %data=('type'=>'hid', 'value'=>$value);
   $data{'date_store'} = time();

   my $rv=sqlInsertUpdate4x($dbh,'cnm_services',\%data,\%data);
   $self->error($libSQL::err);
   $self->errorstr($libSQL::errstr);
   $self->lastcmd($libSQL::cmd);

   if ($libSQL::err) {
      $self->manage_db_error($dbh,"store_cnm_services_hid");
      return undef;
   }

   return;
}


#----------------------------------------------------------------------------
# get_cnm_config
# Out: ref a un hash con la configuracion de sistema en BBDD
#----------------------------------------------------------------------------
sub get_cnm_config  {
my ($self,$dbh)=@_;


   my %config=();
   my $rres=sqlSelectAll(  $dbh,
                           'cnm_key,cnm_value',
                           'cnm_config',
                           '',
                           '' );

   foreach my $v (@$rres) {  	$config{$v->[0]}=$v->[1];   }

   return \%config;
}



#----------------------------------------------------------------------------
# get_outside_correlation_rules
# Out: %config
# Cada clave es el valor del id_dev del dispositivo correlado.
# Cada valor es una ref a un array de clave id_dev.mname que indican el dispositivo 
# y la metrica que originan la correlacion.
#----------------------------------------------------------------------------
sub get_outside_correlation_rules  {
my ($self,$dbh)=@_;


   my %config=();
   my $rres=sqlSelectAll(  $dbh,
     	                   	'id_dev,mname,id_dev_correlated',
      	                  'cfg_outside_correlation_rules',
         	               '',
            	            '' );

   foreach my $v (@$rres) {
      my $id_dev_correlated=$v->[2];
		if ($v->[1] eq 'disp_icmp') { $v->[1]='mon_icmp'; }
		my $key=$v->[0].'.'.$v->[1];
      if (exists $config{$key}) {push @{$config{$key}}, $id_dev_correlated; }
      else { $config{$key}=[ $id_dev_correlated ]; }
#      if (exists $config{$id_dev_correlated}) {push @{$config{$id_dev_correlated}}, $key; }
#      else { $config{$id_dev_correlated}=[ $key ]; }

	}

	return \%config;
}

#----------------------------------------------------------------------------
# analize_views_ruleset
# Out: %VIEWS2ALERTS
# Es un hash que contiene el numero de alertas rojas,naranjes y amarillas de la
# vista junto con la su severidad en base al ruleset que tenga definida.
#----------------------------------------------------------------------------
sub analize_views_ruleset  {
my ($self,$dbh,$cid,$cid_ip)=@_;


	# id_metric -> severity de la alerta
	my $METRIC2SEVERITY=$self->get_metric2severity($dbh);
	# id_dev_id_remote -> severity de la alerta
	my $REMOTE2SEVERITY=$self->get_remote2severity($dbh);

	# id__cfg_view -> vector con sus reglas
	my $RULESET=$self->get_viewsruleset($dbh);

	# id__cfg_view -> vector con sus alertas
	my $VIEW_ALERTS=$self->get_view_alerts($dbh);


print '-'x60, "**METRIC2SEVERITY**\n";
print Dumper($METRIC2SEVERITY);
print '-'x60, "**REMOTE2SEVERITY**\n";
print Dumper($REMOTE2SEVERITY);
print '-'x60, "**RULESET**\n";
print Dumper($RULESET);
print '-'x60, "\n";
print '-'x60, "**VIEW_ALERTS**\n";
print Dumper($VIEW_ALERTS);
print '-'x60, "\n";


   #-----------------------------------------------
   my $rres;
   my ($what, $from, $where, $other) = ('', '', '', '');

   my %PH=();
   #-----------------------------------------------
   $rres=sqlSelectAll(  $dbh, 'id_cfg_view,id_cfg_subview', 'cfg_views2views', '', '' );
   foreach my $v (@$rres) {
      my $id_cfg_view=$v->[0];
      my $id_cfg_subview=$v->[1];
      if (exists $PH{$id_cfg_view}) { push @{$PH{$id_cfg_view}}, $id_cfg_subview; }
      else { $PH{$id_cfg_view} = [$id_cfg_subview];  }
   }

   #-----------------------------------------------
   # VIEWS2ALERTS contiene el mapeo de cada vista con sus alertas correspondientes
   # Inicializamos todos los valores posibles del vector %VIEWS2ALERTS
	# CFGVIEWS 
   my %CFGVIEWS=();
   my %VIEWS2ALERTS=();
   my @defined_views=();
   #-----------------------------------------------
   $rres=sqlSelectAll($dbh, 'id_cfg_view,ruled,name', 'cfg_views', "cid=\'$cid\' and cid_ip=\'$cid_ip\'", '');
   foreach my $v (@$rres) {
      my $id_cfg_view=$v->[0];
      my $ruled=$v->[1];
		my $n=$v->[2];
      $VIEWS2ALERTS{$id_cfg_view}={'severity'=>0, 'v1'=>0, 'v2'=>0, 'v3'=>0, 'v4'=>0, 'ruled'=>$ruled };
      push @defined_views, $id_cfg_view;

      my ($has_subviews,$done)=(0,1);
      if (exists $PH{$id_cfg_view}) { $has_subviews=1; $done=0; }
      $CFGVIEWS{$id_cfg_view} = { 'has_subviews'=> $has_subviews, 'done'=> $done, 'v1'=>0, 'v2'=>0, 'v3'=>0, 'name'=>$n };
   }


	my %VIEWS2METRICS=();
   # Para cada metrica de cada vista se mira si esta alertada.
   # En caso afirmativo se pone el flag en VIEWS2METRICS 
   # Compone el hash %VIEWS2METRICS $id_cfg_view -> $id_metric -> v1,v2,v3 o v4
   # que indica para cada vista la severidad de sus metricas
   $rres=sqlSelectAll(	$dbh, 
								'v.id_cfg_view,c.id_metric', 
								'cfg_views v, cfg_views2metrics c', 
								"v.id_cfg_view=c.id_cfg_view AND cid=\'$cid\' AND cid_ip=\'$cid_ip\'", 
								'' );

   foreach my $v (@$rres) {
      my $id_cfg_view=$v->[0];
      my $id_metric=$v->[1];

      if (exists $METRIC2SEVERITY->{$id_metric}) {
         if ($METRIC2SEVERITY->{$id_metric} == 1) {
            $VIEWS2METRICS{$id_cfg_view}->{$id_metric}->{'v1'} = 1;
				$VIEWS2ALERTS{$id_cfg_view}->{'v1'} += 1;
				$self->log('debug',"analize_views_ruleset::VIEWS2METRICS ALERT v1 id_cfg_view=$id_cfg_view id_metric=$id_metric");
         }
         elsif ($METRIC2SEVERITY->{$id_metric} == 2) {
            $VIEWS2METRICS{$id_cfg_view}->{$id_metric}->{'v2'} = 1;
				$VIEWS2ALERTS{$id_cfg_view}->{'v2'} += 1;
				$self->log('debug',"analize_views_ruleset::VIEWS2METRICS ALERT v2 id_cfg_view=$id_cfg_view id_metric=$id_metric");
         }
         elsif ($METRIC2SEVERITY->{$id_metric} == 3) {
            $VIEWS2METRICS{$id_cfg_view}->{$id_metric}->{'v3'} = 1;
				$VIEWS2ALERTS{$id_cfg_view}->{'v3'} += 1;
				$self->log('debug',"analize_views_ruleset::VIEWS2METRICS ALERT v3 id_cfg_view=$id_cfg_view id_metric=$id_metric");
         }
         else {
            $VIEWS2METRICS{$id_cfg_view}->{$id_metric}->{'v4'} = 1;
				$VIEWS2ALERTS{$id_cfg_view}->{'v4'} += 1;
				$self->log('debug',"analize_views_ruleset::VIEWS2METRICS ALERT v3 id_cfg_view=$id_cfg_view id_metric=$id_metric");
         }
      }
   }

   #-----------------------------------------------
	my %VIEWS2REMOTE=();
   # Compone el hash %VIEWS2REMOTE $id_cfg_view -> $id_remote_alert -> v1,v2,v3 o v4
   $rres=sqlSelectAll(	$dbh, 
								'v.id_cfg_view,c.id_remote_alert,c.id_dev', 
								'cfg_views v, cfg_views2remote_alerts c', 
								'v.id_cfg_view=c.id_cfg_view', 
								'' );
   foreach my $v (@$rres) {
      my $id_cfg_view=$v->[0];
      my $id_remote_alert=$v->[1];
      my $id_device=$v->[2];
      my $id=$id_remote_alert.'-'.$id_device;

      if (exists $REMOTE2SEVERITY->{$id}) {
         if ($REMOTE2SEVERITY->{$id} == 1) {
            $VIEWS2REMOTE{$id_cfg_view}->{$id}->{'v1'} = 1;
				$VIEWS2ALERTS{$id_cfg_view}->{'v1'} += 1;
				$self->log('debug',"analize_views_ruleset::VIEWS2REMOTE ALERT v1 id_cfg_view=$id_cfg_view id=$id");
         }
         elsif ($REMOTE2SEVERITY->{$id} == 2) {
            $VIEWS2REMOTE{$id_cfg_view}->{$id}->{'v2'} = 1;
				$VIEWS2ALERTS{$id_cfg_view}->{'v2'} += 1;
				$self->log('debug',"analize_views_ruleset::VIEWS2REMOTE ALERT v2 id_cfg_view=$id_cfg_view id=$id");
         }
         elsif ($REMOTE2SEVERITY->{$id} == 3) {
            $VIEWS2REMOTE{$id_cfg_view}->{$id}->{'v3'} = 1;
				$VIEWS2ALERTS{$id_cfg_view}->{'v3'} += 1;
				$self->log('debug',"analize_views_ruleset::VIEWS2REMOTE ALERT v3 id_cfg_view=$id_cfg_view id=$id");
         }
         else {
            $VIEWS2REMOTE{$id_cfg_view}->{$id}->{'v4'} = 1;
				$VIEWS2ALERTS{$id_cfg_view}->{'v4'} += 1;
				$self->log('debug',"analize_views_ruleset::VIEWS2REMOTE ALERT v4 id_cfg_view=$id_cfg_view id=$id");
         }
      }
   }


#   my %PH=();
#   #-----------------------------------------------
#   $rres=sqlSelectAll(  $dbh, 'id_cfg_view,id_cfg_subview', 'cfg_views2views', '', '' );
#   foreach my $v (@$rres) {
#      my $id_cfg_view=$v->[0];
#      my $id_cfg_subview=$v->[1];
#      if (exists $PH{$id_cfg_view}) { push @{$PH{$id_cfg_view}}, $id_cfg_subview; }
#      else { $PH{$id_cfg_view} = [$id_cfg_subview];  }
#   }
#
#   my %CFGVIEWS=();
#   #-----------------------------------------------
#   $rres=sqlSelectAll(  $dbh, 'id_cfg_view,name', 'cfg_views', '', '' );
#   foreach my $v (@$rres) {
#      my $id_cfg_view=$v->[0];
#		my $n = $v->[1];
#      my ($has_subviews,$done)=(0,1);
#      if (exists $PH{$id_cfg_view}) { $has_subviews=1; $done=0; }
#      $CFGVIEWS{$id_cfg_view} = { 'has_subviews'=> $has_subviews, 'done'=> $done, 'v1'=>0, 'v2'=>0, 'v3'=>0, 'name'=>$n };
#   }

   #-----------------------------------------------
   my %VIEWS2VIEWS=();

print '-'x60, "**CFGVIEWS**\n";
print Dumper(\%CFGVIEWS);
print '-'x60, "**PH**\n";
print Dumper(\%PH);
print '-'x60, "\n";

   my $recurse=1;
   my $all_views = scalar (keys %CFGVIEWS);
   my $max_time = time + 15;
   while ($recurse) {
      foreach my $id (reverse sort {$a<=>$b} keys %CFGVIEWS)  {
         $self->summarize_view($dbh,$id,\%CFGVIEWS,\%PH,\%VIEWS2ALERTS,\%VIEWS2VIEWS,\%VIEWS2METRICS,\%VIEWS2REMOTE,$RULESET,$VIEW_ALERTS);
      }

      my $views_done=0;
      foreach my $id (keys %CFGVIEWS)  {
         if ($CFGVIEWS{$id}->{'done'}) { $views_done+=1; }
      }
      if ($views_done == $all_views) { $recurse=0; }
      if (time > $max_time) {
         $recurse=0;
         $self->log('warning',"analize_views_ruleset:: **WARN** RECURSE TIMEOUT");
      }
   }

my $kk=Dumper(\%VIEWS2METRICS);
$self->log('debug',"analize_views_ruleset::VIEWS2METRICS=$kk");
$kk=Dumper(\%VIEWS2VIEWS);
$self->log('debug',"analize_views_ruleset::VIEWS2VIEWS=$kk");
$self->log('debug',"analize_views_ruleset::VIEWS2REMOTE=$kk");
$kk=Dumper(\%VIEWS2ALERTS);
#open (F,'>/tmp/VIEWS2ALERTS');
#print F "$kk\n";
#close F;
$self->log('debug',"analize_views_ruleset::VIEWS2ALERTS=$kk");
$kk=Dumper($RULESET);
$self->log('debug',"analize_views_ruleset::RULESET=$kk");

	# --------------------------------------------------------------------------------
	# Se calcula la severidad de la vista
	# a. Si tiene reglas, se utilizan
	# b. Si no tiene reglas es la de laalerta de mayor peso.
	# --------------------------------------------------------------------------------
   foreach my $id_cfg_view (keys %VIEWS2ALERTS) {

		# $ruleset contiene un array con las reglas de la vista siempre que ruled=1;
      my $ruleset = (exists $RULESET->{$id_cfg_view}) ? $RULESET->{$id_cfg_view} : [];

		if (ref ($VIEWS2ALERTS{$id_cfg_view}) ne "HASH") {next; }

		if (! $VIEWS2ALERTS{$id_cfg_view}->{'ruled'}) { $ruleset = []; }
	
		$VIEWS2ALERTS{$id_cfg_view}->{'severity'}=6;

		# ------------------------------------------------------------					
		# Calcula la severidad de la vista en funcion de las reglas
		# ------------------------------------------------------------					
		if (scalar(@$ruleset) > 0) {
			$VIEWS2ALERTS{$id_cfg_view}->{'severity'}=$self->_get_severity_by_rules($dbh,$id_cfg_view,$ruleset,\%VIEWS2ALERTS,\%VIEWS2METRICS,\%VIEWS2REMOTE,\%VIEWS2VIEWS,$VIEW_ALERTS);
		}

		# ------------------------------------------------------------					
		# Calcula la severidad de la vista en funcion del num. de alertas
		# ------------------------------------------------------------					
		if (scalar(@$ruleset) == 0) {

			$VIEWS2ALERTS{$id_cfg_view}->{'severity'}=$self->_get_severity_by_alerts($id_cfg_view,\%VIEWS2ALERTS);
		}
   }

   #-----------------------------------------------
	# Las alertas que hayan desaparecido se eliminan de view_alerts_store
	foreach my $id_cfg_view (keys %$VIEW_ALERTS) {
		foreach my $id_cfg_viewsruleset (keys %{$VIEW_ALERTS->{$id_cfg_view}}) {

        	$VIEW_ALERTS->{$id_cfg_view}->{$id_cfg_viewsruleset}->{'id_cfg_view'}=$id_cfg_view;
         $VIEW_ALERTS->{$id_cfg_view}->{$id_cfg_viewsruleset}->{'id_cfg_viewsruleset'}=$id_cfg_viewsruleset;
			if ((exists $VIEW_ALERTS->{$id_cfg_view}->{$id_cfg_viewsruleset}->{'dbaction'}) &&
				($VIEW_ALERTS->{$id_cfg_view}->{$id_cfg_viewsruleset}->{'dbaction'} eq 'SET')) {
	         	$self->store_view_alert($dbh,'view_alerts',$VIEW_ALERTS->{$id_cfg_view}->{$id_cfg_viewsruleset});
			}
			else {
				$self->clear_view_alert($dbh,$VIEW_ALERTS->{$id_cfg_view}->{$id_cfg_viewsruleset});	
			}
		}
	}


   #-----------------------------------------------
   # Se  actualiza el estado en cfg_views
	my $cview=0;
   foreach my $id (keys %VIEWS2ALERTS) {
      my %table=();
		if (ref ($VIEWS2ALERTS{$id}) ne "HASH") {next; }

      $table{'severity'}=$VIEWS2ALERTS{$id}->{'severity'};
      $table{'red'} = $VIEWS2ALERTS{$id}->{'v1'} || 0;
      $table{'orange'}=$VIEWS2ALERTS{$id}->{'v2'} || 0;
      $table{'yellow'}=$VIEWS2ALERTS{$id}->{'v3'} || 0;
      $table{'blue'}=$VIEWS2ALERTS{$id}->{'v4'} || 0;

      sqlUpdate($dbh,'cfg_views',\%table,"id_cfg_view=$id and cid=\'$cid\' and cid_ip=\'$cid_ip\'");
		$cview++;

		$self->log('debug',"analize_views_ruleset:: UPDATEDB id_cfg_view=$id severity=$table{'severity'} red=$table{'red'} orange=$table{'orange'} yellow=$table{'yellow'} blue=$table{'blue'} cid=$cid cid_ip=$cid_ip ($libSQL::errstr)");
   }

	$self->log('info',"analize_views_ruleset:: UPDATEDB TOTAL=$cview vistas");
	
   return (\%VIEWS2ALERTS);
}


#----------------------------------------------------------------------------
# get_view_component_status
#----------------------------------------------------------------------------
sub get_view_component_status  {
#my ($self,$id_cfg_view,$v2metric,$v2remote,$v2view,$info)=@_;
my ($self,$id_cfg_view,$id_cfg_viewsruleset,$v2metric,$v2remote,$v2view,$info,$views2alerts)=@_;


#                         'sev' => '1',
#                         'id' => '187',
#                         'descr' => 'DISPONIBILIDAD ICMP (ping) (srvfact001.s30labs.com)',
#                         'type' => 'metric',
#                         'id_dev' => ''


	my $rc = 0;
	if (ref($info) ne 'HASH') { 
		$self->log('info',"get_view_component_status:: ruleset=$id_cfg_viewsruleset Termino - El parametro no es un hash");
		return $rc;
	}

	my $id = $info->{'id'};
	my $id_dev = $info->{'id_dev'};
	my $sev=$info->{'sev'};
	my $sev_tag = 'v1';
	if ($info->{'sev'}== 2) { $sev_tag = 'v2'; }
	elsif ($info->{'sev'}== 3) { $sev_tag = 'v3'; }

	my $type = $info->{'type'};
	if ($type eq 'metric') {
		if (exists $v2metric->{$id_cfg_view}->{$id}->{$sev_tag}) { $rc=1; } 
	}
	elsif ($type eq 'remote') {
		if (exists $v2remote->{$id_cfg_view}->{$sev_tag}) { $rc=1; }
	}
	elsif ($type eq 'view') {
		#if (exists $v2view->{$id_cfg_view}->{$sev_tag}) { $rc=1; }
		if ($views2alerts->{$id}->{'ruled'}) {
			if ($views2alerts->{$id}->{'severity'} == $info->{'sev'}) { $rc=1; }
		}
		else {
			if ($views2alerts->{$id}->{$sev_tag}>0) { $rc=1; }
		}
	}
	else {
		$self->log('info',"get_view_component_status:: ruleset=$id_cfg_viewsruleset Termino - El tipo del elemento no es correcto ($type)");
	}

	$self->log('info',"get_view_component_status:: ruleset=$id_cfg_viewsruleset id_cfg_view=$id_cfg_view [rc=$rc] id=$id id_dev=$id_dev sev=$sev sev_tag=$sev_tag type=$type [$info->{'descr'}]");

	return $rc;

}

#----------------------------------------------------------------------------
# _get_severity_by_alerts
#----------------------------------------------------------------------------
sub _get_severity_by_alerts  {
my ($self,$id,$VIEWS2ALERTS)=@_;

	my $severity=6;
   if ((exists $VIEWS2ALERTS->{$id}->{'v1'}) && ($VIEWS2ALERTS->{$id}->{'v1'}>0)) { $severity=1; }
   elsif ((exists $VIEWS2ALERTS->{$id}->{'v2'}) && ($VIEWS2ALERTS->{$id}->{'v2'}>0)) { $severity=2; }
   elsif ((exists $VIEWS2ALERTS->{$id}->{'v3'}) && ($VIEWS2ALERTS->{$id}->{'v3'}>0)) { $severity=3; }
	return $severity;
}


#----------------------------------------------------------------------------
# _get_severity_by_rules
#----------------------------------------------------------------------------
sub _get_severity_by_rules  {
my ($self,$dbh,$id_cfg_view,$ruleset,$VIEWS2ALERTS,$VIEWS2METRICS,$VIEWS2REMOTE,$VIEWS2VIEWS,$VIEW_ALERTS)=@_;

   my $severity=6;
   $VIEWS2ALERTS->{$id_cfg_view}->{'v1'}=0;
   $VIEWS2ALERTS->{$id_cfg_view}->{'v2'}=0;
   $VIEWS2ALERTS->{$id_cfg_view}->{'v3'}=0;
	$VIEWS2ALERTS->{$id_cfg_view}->{'severity'}=$severity;

	foreach my $r (@$ruleset) {
	
	   my $rule_int;
   	eval {
      	$rule_int=decode_json($r->{'rule_int'});
   	};
   	if ($@) {
      	my $aux=$r->{'rule_int'};
  			$self->log('info',"_get_severity_by_rules:: ERROR decode json SATTO RULE -$aux- id_cfg_view=$id_cfg_view");
      	next;
   	}

#rule_int = {
#          'items' => { 'v0' =>
#                       {
#                         'sev' => '1',
#                         'id' => '187',
#                         'descr' => 'DISPONIBILIDAD ICMP (ping) (srvfact001.s30labs.com)',
#                         'type' => 'metric',
#                         'id_dev' => ''
#                       }
#                     },
#          'expr' => 'v0'
#        };

#print '-'x60, "\n";
#print Dumper($rule);

   	my $rule_descr = $r->{'descr'};
   	my $expr = $rule_int->{'expr'};
		my $id_cfg_viewsruleset = $r->{'id_cfg_viewsruleset'};
   	my $expr_mod = $expr;
   	my $nvals = scalar(keys %{$rule_int->{'items'}});
		$self->log('info',"_get_severity_by_rules:: ---RULE START--- ruleset=$id_cfg_viewsruleset [$nvals items] expr=[$expr] sev=$severity id_cfg_view=$id_cfg_view [rule=$rule_descr]");

   	for my $i (0..$nvals-1) {
      	my $vx='v'.$i;
			my $val = $self->get_view_component_status($id_cfg_view,$id_cfg_viewsruleset,$VIEWS2METRICS,$VIEWS2REMOTE,$VIEWS2VIEWS,$rule_int->{'items'}->{$vx},$VIEWS2ALERTS);
      	$expr_mod =~ s/$vx/$val/g;
			$self->log('info',"_get_severity_by_rules:: RULE PART ruleset=$id_cfg_viewsruleset [v=$vx] expr_mod=$expr_mod  id_cfg_view=$id_cfg_view [rule=$rule_descr]");
   	}

   	#Sustituyo or por ||
   	while ($expr_mod =~ s/or/\|\|/gi) {}
   	#Sustituyo and por &&
   	while ($expr_mod =~ s/and/\&\&/gi) {}

   	#OJO !!! el eval devuelve 1 si true y nada si false.
   	# Para hacer el eval 'untainted'
   	my $expr_value=0;
   	if ($expr_mod =~ /(.+)/) { $expr_value = eval $1; }

		$self->log('info',"_get_severity_by_rules:: RULE END ruleset=$id_cfg_viewsruleset RES=$expr_value [$expr] -> [$expr_mod]  id_cfg_view=$id_cfg_view [rule=$rule_descr]");

   	if ($expr_value) {

			# Severidad de la alerta en curso.
			my $sev_in_db = $VIEW_ALERTS->{$id_cfg_view}->{$id_cfg_viewsruleset}->{'severity'};

			# Severidad definida en la regla.
      	my $sev = $r->{'sev'};
      	if ($sev == 1) {
         	$VIEWS2ALERTS->{$id_cfg_view}->{'v1'}+=1;
      	}
      	elsif ($sev == 2) {
         	$VIEWS2ALERTS->{$id_cfg_view}->{'v2'}+=1;
      	}
      	elsif ($sev == 3) {
         	$VIEWS2ALERTS->{$id_cfg_view}->{'v3'}+=1;
      	}

			$self->log('info',"_get_severity_by_rules:: **RULE SET ALERT** ruleset=$id_cfg_viewsruleset SEV=$sev ($sev_in_db)  id_cfg_view=$id_cfg_view [rule=$rule_descr]");

			if (! exists $VIEW_ALERTS->{$id_cfg_view}->{$id_cfg_viewsruleset}){
				$VIEW_ALERTS->{$id_cfg_view}->{$id_cfg_viewsruleset} = {'id_cfg_view'=>$id_cfg_view, 'id_cfg_viewsruleset'=>$id_cfg_viewsruleset, 'severity'=>$sev, 'event_data'=>$expr_mod, 'dbaction'=>'SET' };
			}
			#Caso de una regla que ha cambiado su severidad
         elsif ($sev_in_db != $sev) {
				$VIEW_ALERTS->{$id_cfg_view}->{$id_cfg_viewsruleset}->{'id_cfg_view'}=$id_cfg_view;
				$VIEW_ALERTS->{$id_cfg_view}->{$id_cfg_viewsruleset}->{'id_cfg_viewsruleset'}=$id_cfg_viewsruleset;
				$self->clear_view_alert($dbh,$VIEW_ALERTS->{$id_cfg_view}->{$id_cfg_viewsruleset});
            $VIEW_ALERTS->{$id_cfg_view}->{$id_cfg_viewsruleset} = {'id_cfg_view'=>$id_cfg_view, 'id_cfg_viewsruleset'=>$id_cfg_viewsruleset, 'severity'=>$sev, 'event_data'=>$expr_mod, 'dbaction'=>'SET'};
         }

			else { 
				$VIEW_ALERTS->{$id_cfg_view}->{$id_cfg_viewsruleset}->{'dbaction'}='SET';
				$VIEW_ALERTS->{$id_cfg_view}->{$id_cfg_viewsruleset}->{'severity'}=$sev;
				$VIEW_ALERTS->{$id_cfg_view}->{$id_cfg_viewsruleset}->{'event_data'}=$expr_mod;
			}

			if ($sev < $severity) { $severity = $sev; } 
   	}
	}

	$VIEWS2ALERTS->{$id_cfg_view}->{'severity'}=$severity;
   if ($VIEWS2ALERTS->{$id_cfg_view}->{'severity'} == 6) {
      $VIEWS2ALERTS->{$id_cfg_view}->{'v1'}=0;
      $VIEWS2ALERTS->{$id_cfg_view}->{'v2'}=0;
      $VIEWS2ALERTS->{$id_cfg_view}->{'v3'}=0;
   }

	$self->log('debug',"_get_severity_by_rules:: RESULTADO >> id_cfg_view=$id_cfg_view severity=$severity-----");

	return $severity;
}

#----------------------------------------------------------------------------
# summarize_view
#n----------------------------------------------------------------------------
sub summarize_view  {
my ($self,$dbh,$id,$CFGVIEWS,$PH,$VIEWS2ALERTS,$VIEWS2VIEWS,$VIEWS2METRICS,$VIEWS2REMOTE,$RULESET,$VIEW_ALERTS)=@_;

   my $done = (exists $CFGVIEWS->{$id}->{'done'}) ? $CFGVIEWS->{$id}->{'done'} : '';
   $self->log('info',"summarize_view:: START ID=$id DONE=$done");

   if ($CFGVIEWS->{$id}->{'done'}) { return; }

   foreach my $id_child (@{$PH->{$id}}) {
      $self->log('info',"summarize_view:: LOOP ID=$id TIENE HIJO id_child=$id_child con done=$CFGVIEWS->{$id_child}->{'done'}");

      if (($CFGVIEWS->{$id_child}->{'has_subviews'}) && ($CFGVIEWS->{$id_child}->{'done'}==0)) {
         $self->log('debug',"summarize_view:: RECURSE id_child=$id_child -------------------------");
         $self->summarize_view($dbh,$id_child,$CFGVIEWS,$PH,$VIEWS2ALERTS,$VIEWS2VIEWS);
         $self->log('debug',"summarize_view:: RECURSE id_child=$id_child -------------------------");
      }
  #    elsif ($VIEWS2ALERTS->{$id_child}->{'ruled'}) {

#		else {

      	my $ruleset = (exists $RULESET->{$id_child}) ? $RULESET->{$id_child} : [];
			if (scalar(@$ruleset)) {
         	$VIEWS2ALERTS->{$id_child}->{'severity'}=$self->_get_severity_by_rules($dbh,$id_child,$ruleset,$VIEWS2ALERTS,$VIEWS2METRICS,$VIEWS2REMOTE,$VIEWS2VIEWS,$VIEW_ALERTS);
			}

#         $CFGVIEWS->{$id}->{'done'}=1;
#		}
#
#		else {
		
			if ((exists $VIEWS2ALERTS->{$id_child}->{'v1'}) && ($VIEWS2ALERTS->{$id_child}->{'v1'} > 0)) {
            $VIEWS2VIEWS->{$id}->{'v1'} = 1;
            $VIEWS2ALERTS->{$id}->{'v1'} += $VIEWS2ALERTS->{$id_child}->{'v1'};
            $self->log('debug',"summarize_view:: LOOP ID=$id (++) TIENE HIJO id_child=$id_child SUMO ROJAS $VIEWS2ALERTS->{$id_child}->{'v1'}");
         }
			elsif ((exists $VIEWS2ALERTS->{$id_child}->{'v2'}) && ($VIEWS2ALERTS->{$id_child}->{'v2'} > 0)) {
            $VIEWS2VIEWS->{$id}->{'v2'} = 1;
            $VIEWS2ALERTS->{$id}->{'v2'} += $VIEWS2ALERTS->{$id_child}->{'v2'};
            $self->log('debug',"summarize_view:: LOOP ID=$id (++) TIENE HIJO id_child=$id_child SUMO NARANJAS $VIEWS2ALERTS->{$id_child}->{'v2'}");
         }
			elsif ((exists $VIEWS2ALERTS->{$id_child}->{'v3'}) && ($VIEWS2ALERTS->{$id_child}->{'v3'} > 0)) {
            $VIEWS2VIEWS->{$id}->{'v3'} = 1;
            $VIEWS2ALERTS->{$id}->{'v3'} += $VIEWS2ALERTS->{$id_child}->{'v3'};
            $self->log('debug',"summarize_view:: LOOP ID=$id (++) TIENE HIJO id_child=$id_child SUMO AMARILLAS $VIEWS2ALERTS->{$id_child}->{'v3'}");
         }
			elsif ((exists $VIEWS2ALERTS->{$id_child}->{'v4'}) && ($VIEWS2ALERTS->{$id_child}->{'v4'} > 0)) {
            $VIEWS2VIEWS->{$id}->{'v4'} = 1;
            $VIEWS2ALERTS->{$id}->{'v4'} += $VIEWS2ALERTS->{$id_child}->{'v4'};
            $self->log('debug',"summarize_view:: LOOP ID=$id (++) TIENE HIJO id_child=$id_child SUMO AZULES $VIEWS2ALERTS->{$id_child}->{'v4'}");
         }
         else {
            $self->log('debug',"summarize_view:: LOOP ID=$id TIENE HIJO id_child=$id_child SIN ALERTAS");
         }

         $CFGVIEWS->{$id}->{'done'}=1;

    #  }

   }

   if ((exists $CFGVIEWS->{$id}->{'done'}) && ($CFGVIEWS->{$id}->{'done'}==0)) { 
		$self->summarize_view($dbh,$id,$CFGVIEWS,$PH,$VIEWS2ALERTS,$VIEWS2VIEWS,$VIEWS2METRICS,$VIEWS2REMOTE,$RULESET); 
	}

   $done=$CFGVIEWS->{$id}->{'done'};
   $self->log('info',"summarize_view:: END ID=$id DONE=$done");

}


#----------------------------------------------------------------------------
# get_metric2severity
#----------------------------------------------------------------------------
sub get_metric2severity  {
my ($self,$dbh)=@_;


   my $rres;

   #-----------------------------------------------
   # METRIC2SEVERITY contiene el vector de metricas en estado de alerta
   # Se contempla el caso icmp como especial porque a todos los efextos mon_icmp y disp_icmp es lo mismo y en una vista
   # puede estar asociada cualquiera de las dos.
   #
   # SELECT m.label,m.name,m.id_metric,1 as severity FROM  metrics m WHERE m.id_dev in (SELECT id_device FROM alerts a WHERE a.mname like '%icmp' and a.counter>0) and m.name like '%icmp';
   # SELECT m.label,m.id_metric,a.severity FROM alerts a, metrics m WHERE a.mname not like '%icmp' and a.id_device=m.id_dev and a.mname=m.name and a.counter>0;
   # Por otra parte, el caso de sin respuesta snmp o sin respuesta de agente remoto no se contemplan.
   my %METRIC2SEVERITY=();
	# Metricas tipo icmp
   $rres=sqlSelectAll(	$dbh, 
								'm.id_metric,1 as severity', 
								'metrics m', 
								"m.id_dev in (SELECT id_device FROM alerts a WHERE a.mname like \'%icmp\' and a.counter>0) and m.name like \'%icmp\'", 
								'');

   foreach my $v (@$rres) {
      my $id_metric=$v->[0];
      my $severity=$v->[1];
      $METRIC2SEVERITY{$id_metric}=$severity;
   }

	# Resto de metricas
   $rres=sqlSelectAll(	$dbh, 
								'm.id_metric,a.severity', 
								'alerts a, metrics m', 
								"a.mname not like \'%icmp\' and a.id_device=m.id_dev and a.mname=m.name and a.counter>0",
								'');

   foreach my $v (@$rres) {
      my $id_metric=$v->[0];
      my $severity=$v->[1];
      $METRIC2SEVERITY{$id_metric}=$severity;
   }

	return (\%METRIC2SEVERITY);

}

#----------------------------------------------------------------------------
# get_remote2severity
#----------------------------------------------------------------------------
sub get_remote2severity  {
my ($self,$dbh)=@_;


   my $rres;

   #-----------------------------------------------
   #select id_metric as id_remote_alert,severity from alerts where type ='snmp-trap';
   # REMOTE2SEVERITY contiene el vector de alertas remotas en estado de alerta
   my %REMOTE2SEVERITY=();
   $rres=sqlSelectAll(	$dbh, 
								'id_metric as id_remote_alert,id_device,severity',
								'alerts a', 
								"type IN (\'snmp-trap\',\'api\',\'email\',\'syslog\')  AND a.counter>0", 
								'');

   foreach my $v (@$rres) {
      my $id_remote_alert=$v->[0];
      my $id_device=$v->[1];
      my $severity=$v->[2];
      my $id=$id_remote_alert.'-'.$id_device;
      $REMOTE2SEVERITY{$id}=$severity;
   }

	return (\%REMOTE2SEVERITY);

}


#----------------------------------------------------------------------------
# get_viewsruleset
#----------------------------------------------------------------------------
sub get_viewsruleset  {
my ($self,$dbh)=@_;


   my $rres;

#mysql> select id_cfg_view,severity,weight,rule_int from cfg_viewsruleset;
#+-------------+----------+--------+----------------------------------------------------------------------+
#| id_cfg_view | severity | weight | rule_int                                                             |
#+-------------+----------+--------+----------------------------------------------------------------------+
#|           2 |        1 |    100 |  RED(metric_1268)  OR  ORANGE(metric_1268)  OR  YELLOW(metric_1268)  |
#

   my %RULESET=();
   $rres=sqlSelectAll(  $dbh,
                        'id_cfg_view,descr,severity,rule_int,id_cfg_viewsruleset',
                        'cfg_viewsruleset',
                        '',
                        'order by severity');

   foreach my $v (@$rres) {
      my $id_cfg_view=$v->[0];
      my $descr=$v->[1];
      my $severity=$v->[2];
      my $rule_int=$v->[3];
		my $id_cfg_viewsruleset=$v->[4];
      if (exists $RULESET{$id_cfg_view}) {push @{$RULESET{$id_cfg_view}}, { 'rule_int'=>$rule_int, 'descr'=>$descr, 'sev'=>$severity, 'id_cfg_viewsruleset'=>$id_cfg_viewsruleset }; }
		else { $RULESET{$id_cfg_view}=[{'rule_int'=>$rule_int, 'descr'=>$descr, 'sev'=>$severity, 'id_cfg_viewsruleset'=>$id_cfg_viewsruleset }]; }
   }
	return (\%RULESET);

}


#----------------------------------------------------------------------------
# get_view_alerts
#----------------------------------------------------------------------------
sub get_view_alerts  {
my ($self,$dbh)=@_;

   my $rres;

#mysql> SELECT id_alert,id_cfg_view,id_cfg_viewsruleset,severity,date,ack,counter,event_data,date_last FROM view_alerts;

   my %VIEW_ALERTS=();
   $rres=sqlSelectAll(  $dbh,
                        'id_alert,id_cfg_view,id_cfg_viewsruleset,severity,date,ack,counter,event_data,date_last',
                        'view_alerts',
                        '',
                        '');

   foreach my $v (@$rres) {
      my $id_alert=$v->[0];
      my $id_cfg_view=$v->[1];
      my $id_cfg_viewsruleset=$v->[2];
      my $severity=$v->[3];
      my $date=$v->[4];
      my $ack=$v->[5];
      my $counter=$v->[6];
      my $event_data=$v->[7];
      my $date_last=$v->[8];

		$VIEW_ALERTS{$id_cfg_view}->{$id_cfg_viewsruleset}={ 'id_alert'=>$id_alert, 'id_cfg_viewsruleset'=>$id_cfg_viewsruleset, 'severity'=>$severity, 'date'=>$date, 'ack'=>$ack, 'counter'=>$counter, 'event_data'=>$event_data, 'date_last'=>$date_last, 'checked'=>0 };

#      if (exists $VIEW_ALERTS{$id_cfg_view}) {
#			push @{$VIEW_ALERTS{$id_cfg_view}}, { 'id_alert'=>$id_alert, 'id_cfg_viewsruleset'=>$id_cfg_viewsruleset, 'sev'=>$severity, 'date'=>$date, 'ack'=>$ack, 'counter'=>$counter, 'event_data'=>$event_data, 'date_last'=>$date_last }; 
#		}
#      else { 
#			$VIEW_ALERTS{$id_cfg_view}=[{ 'id_alert'=>$id_alert, 'id_cfg_viewsruleset'=>$id_cfg_viewsruleset, 'sev'=>$severity, 'date'=>$date, 'ack'=>$ack, 'counter'=>$counter, 'event_data'=>$event_data, 'date_last'=>$date_last }]; 
#		}

   }
   return (\%VIEW_ALERTS);

}

#----------------------------------------------------------------------------
# Funcion: store_view_alert
# Descripcion:
# Se actualiza alerta de vista en view_alerts
# Se inserta nueva alerta de vista en view_alerts
# $dbtable = view_alerts | view_alerts_store
#----------------------------------------------------------------------------
sub store_view_alert {
my ($self,$dbh,$dbtable,$data)=@_;

   if (! defined $dbtable) {
      $self->log('info',"store_view_alert:: ERROR No definido dbtable");
      return undef;
   }

   if ((! defined $data) || (ref($data) ne 'HASH')) {
      $self->log('info',"store_view_alert:: ERROR No definido data");
      return undef;
   }

 #  my %table=( 'id_alert'=>0, 'id_cfg_view'=>0, 'id_cfg_viewsruleset'=>0, 'severity'=>1, 'date'=>0, 'counter'=>0, 'event_data'=>'', 'date_last'=>0 );

	my %table=();
	my $ts=time();
   if (exists $data->{'id_cfg_view'}) { $table{'id_cfg_view'}=$data->{'id_cfg_view'}; }
   if (exists $data->{'id_cfg_viewsruleset'}) { $table{'id_cfg_viewsruleset'}=$data->{'id_cfg_viewsruleset'}; }
   if (exists $data->{'severity'}) { $table{'severity'}=$data->{'severity'}; }
	# Si estamos almacenando alertas activas. La primera vez no existe counter y las sucesivas veces se debe incrementar
	# Por otra parte, date solo se debe almacenar la primera vez. Es la fecha/hora en la que ocurre la alerta.
	if ($dbtable eq 'view_alerts') {
	   if (exists $data->{'counter'}) { $table{'counter'}=$data->{'counter'}+1; }
		else { $table{'date'}=$ts; }
		$table{'date_last'}=$ts;
	}
	else {
	   if (exists $data->{'id_alert'}) { $table{'id_alert'}=$data->{'id_alert'}; }
	   if (exists $data->{'counter'}) { $table{'counter'}=$data->{'counter'}; }
		if (exists $data->{'date'}) { $table{'date'}=$data->{'date'}; }
		if (exists $data->{'date_last'}) { $table{'date_last'}=$data->{'date_last'}; }
		$table{'date_store'}=$ts;
	}
   if (exists $data->{'event_data'}) { $table{'event_data'}=$data->{'event_data'}; }

   #------------------------------------------------------------------------
   my $rv=sqlInsertUpdate4x($dbh,$dbtable,\%table,\%table);
   $self->error($libSQL::err);
   $self->errorstr($libSQL::errstr);
   $libSQL::cmd =~ s/\n/ \./g;
   $self->lastcmd($libSQL::cmd);

$self->log('info',"store_view_alert:: **DEBUG**  ($libSQL::cmd)");

   if ($libSQL::err) {
      $self->manage_db_error($dbh,"store_view_alert");
      return undef;
   }
   return $rv;

}

#----------------------------------------------------------------------------
# Funcion: clear_view_alert
# Descripcion:
# Se elimina alerta de view_alerts (desaparece error) y se guarda en view_alerts_store
#----------------------------------------------------------------------------
sub clear_view_alert {
my ($self,$dbh,$data)=@_;

	$self->store_view_alert($dbh,'view_alerts_store',$data);

	my $id_alert = $data->{'id_alert'};
   sqlDelete($dbh,'view_alerts',"id_alert=$id_alert");

}


#----------------------------------------------------------------------------
# store_views_summary
#----------------------------------------------------------------------------
#
#
#----------------------------------------------------------------------------
sub store_views_summary  {
my ($self,$dbh,$views2alerts)=@_;


	my %table_data=();
	my $ts=time();
   $table_data{'ts'}=$self->round_time($ts,60);

	foreach my $id_cfg_view (sort keys %$views2alerts) {
		$table_data{'id_cfg_view'}=$id_cfg_view;

		if (ref($views2alerts->{$id_cfg_view}) ne "HASH") {next; }

		$table_data{'severity'}=$views2alerts->{$id_cfg_view}->{'severity'};
		if ($table_data{'severity'} == 6) { $table_data{'severity'}=0; }

		if (exists $views2alerts->{$id_cfg_view}->{'v1'}) { $table_data{'v1'}=$views2alerts->{$id_cfg_view}->{'v1'}; }
		else {
			$table_data{'v1'}=0;
			$self->log('info',"store_views_summary::[INFO] Para id_cfg_view=$id_cfg_view NO EXISTEN ALERTAS v1");
		}

		if (exists $views2alerts->{$id_cfg_view}->{'v2'}) { $table_data{'v2'}=$views2alerts->{$id_cfg_view}->{'v2'}; }
		else {
			$table_data{'v2'}=0;
			$self->log('info',"store_views_summary::[INFO] Para id_cfg_view=$id_cfg_view NO EXISTEN ALERTAS v2");
		}

		if (exists $views2alerts->{$id_cfg_view}->{'v3'}) { $table_data{'v3'}=$views2alerts->{$id_cfg_view}->{'v3'}; }
		else {
			$table_data{'v3'}=0;
			$self->log('info',"store_views_summary::[INFO] Para id_cfg_view=$id_cfg_view NO EXISTEN ALERTAS v3");
		}


      # Almacenamiento RRD --------------------------
      my $data=join(':',$table_data{'ts'},$table_data{'v1'},$table_data{'v2'},$table_data{'v3'},$table_data{'severity'});
      my $views_path='/opt/data/rrd/views';
		if (! -d $views_path) { system("mkdir -p $views_path"); }
      my $rrd=$views_path.'/'.sprintf("%06d", $id_cfg_view).'.rrd';

      my $mode='GAUGE';
      my $lapse=60;
      my $type='H2_AREA';
		my $items=4; #v1,v2,v3,severity

      if (! -e $rrd) { $self->create_rrd($rrd,$items,$mode,$lapse,$table_data{'ts'},$type);  }
      my $r = $self->update_rrd($rrd,$data);
      if ($r) {
         my $ru = unlink $rrd;
         $self->log('info',"store_views_summary::[INFO] Elimino $rrd  ($ru)");
         $self->create_rrd($rrd,$items,$mode,$lapse,$table_data{'ts'},$type);
         $self->update_rrd($rrd,$data);
      }
	}

}


#----------------------------------------------------------------------------
# Funcion: recurse_views
# Descripcion:
#----------------------------------------------------------------------------
sub recurse_views {
my ($self,$views2views,$id_view)=@_;

	my @tree=();
	my $id1=$id_view;
	while (exists $views2views->{$id1}) {
		my $id2=$views2views->{$id1};
		push @tree, $id2;
		$id1=$id2;
	}
	return \@tree;
}

#----------------------------------------------------------------------------
# Funcion: store_event
# Descripcion:
#----------------------------------------------------------------------------
sub store_event {
my ($self,$dbh,$data)=@_;
my %table=();
my $rv=undef;

	if (defined $data->{date}) {$table{date}= $data->{date};}
	else { $self->log('warning',"store_event::[WARN] date=undef"); }
	
	if (defined $data->{code}) {$table{code}= $data->{code};}
	else { $self->log('warning',"store_event::[WARN] code=undef"); }

	if (defined $data->{proccess}) {$table{proccess}= $data->{proccess};}
	else { $self->log('warning',"store_event::[WARN] proccess=undef"); }

	if (defined $data->{msg}) {$table{msg}= $data->{msg};}
	else { $self->log('warning',"store_event::[WARN] msg=undef"); }

   if (defined $data->{msg_custom}) {$table{msg_custom}= $data->{msg_custom};}
   else { $self->log('warning',"store_event::[WARN] msg_custom=undef"); }

   if (defined $data->{evkey}) {$table{evkey}= $data->{evkey};}
   else { $self->log('warning',"store_event::[WARN] evkey=undef"); }

	if (defined $data->{ip}) {$table{ip}= $data->{ip};}
	else { $self->log('warning',"store_event::[WARN] ip=undef"); }

	if (defined $data->{name}) {$table{name}= $data->{name};}
	else { $self->log('warning',"store_event::[WARN] name=undef"); }

	if (defined $data->{domain}) {$table{domain}= $data->{domain};}
	else { $self->log('warning',"store_event::[WARN] domain=undef"); }

	if (defined $data->{id_dev}) {$table{id_dev}= $data->{id_dev}; }

   $rv=sqlInsert($dbh,$TAB_EVENTS_NAME,\%table);
   if (defined $rv) {
      #$self->log('debug',"store_event::[DEBUG] Insert $table{ip}:$table{msg} (RV=$rv)");
   }
   else {
      $self->log('warning',"store_event::[WARN] Error en Insert $table{ip}:$table{msg} (RV=undef) ($libSQL::cmd)");
   }
   return 0;

}




#----------------------------------------------------------------------------
# Funcion: store_service
# Descripcion:
#----------------------------------------------------------------------------
sub store_service {
my ($self,$dbh,$data)=@_;
my %table=();
my $rv=undef;

   if (defined $data->{parent}) {$table{parent}= lc $data->{parent};}
   if (defined $data->{name}) {$table{name}= lc $data->{name};}
   if (defined $data->{description}) {$table{description}= lc $data->{description};}
   if (defined $data->{type}) {$table{type}= lc $data->{type};}
   if (defined $data->{level}) {$table{level}=$data->{level};}

   $rv=sqlInsert($dbh,$TAB_SERVICES_NAME,\%table);
   if (defined $rv) {
      my $rres=sqlSelectAll($dbh,'id_serv',$TAB_SERVICES_NAME,"name=\'$table{name}\'");
      $self->log('debug',"store_service::[DEBUG] Insert service $table{name} [ID=$rres->[0][0]] (RV=$rv)");
      return $rres->[0][0];
   }

   $rv=sqlUpdate($dbh,$TAB_SERVICES_NAME,\%table,"name = \'$table{name}\'");
   if (defined $rv) {
      my $rres=sqlSelectAll($dbh,'id_serv',$TAB_SERVICES_NAME,"name=\'$table{name}\'");
      $self->log('debug',"store_service::[DEBUG] Update service $table{name} [ID=$rres->[0][0]] (RV=$rv)");
      return $rres->[0][0];
   }
   else {
      $self->log('warning',"store_service::[WARN] Error en Insert/Update service $table{name} (RV=undef)");
   }
   return 0;

}

#----------------------------------------------------------------------------
# Funcion: store_notification
# Descripcion:
#----------------------------------------------------------------------------
sub store_notification {
my ($self,$dbh,$data)=@_;
my %table=();
my $rv=undef;

   if (defined $data->{id_cfg_notification}) {$table{id_cfg_notification} = $data->{id_cfg_notification};}
	$table{date}=time;
   if (defined $data->{rc}) {$table{rc}= $data->{rc};}
   if (defined $data->{msg}) {$table{msg}= $data->{msg};}
   if (defined $data->{id_dev}) {$table{id_dev}= $data->{id_dev};}

   $rv=sqlInsert($dbh,$TAB_NOTIFICATIONS_NAME,\%table);
   if (defined $rv) {
      my $rres=sqlSelectAll($dbh,'id_notif',$TAB_NOTIFICATIONS_NAME,"id_cfg_notification=$table{id_cfg_notification}");
      $self->log('debug',"store_notification::[DEBUG] Insert notification $table{msg}(ID_DEV=$table{id_dev}) [ID=$rres->[0][0]] (RV=$rv)");
      return $rres->[0][0];
   }

   $rv=sqlUpdate($dbh,$TAB_NOTIFICATIONS_NAME,\%table,"id_cfg_notification = $table{id_cfg_notification}");
   if (defined $rv) {
      my $rres=sqlSelectAll($dbh,'id_serv',$TAB_NOTIFICATIONS_NAME,"id_cfg_notification=$table{id_cfg_notification}");
      $self->log('debug',"store_notification::[DEBUG] Update notification $table{msg} (ID_DEV=$table{id_dev}) [ID=$rres->[0][0]] (RV=$rv)");
      return $rres->[0][0];
   }
   else {
      $self->log('warning',"store_notification::[WARN] Error en Insert/Update notification $table{msg} (ID_DEV=$table{id_dev}) (RV=undef)");
   }
   return 0;

}

#----------------------------------------------------------------------------
# Funcion: store_cfg_notification
# Descripcion:
#----------------------------------------------------------------------------
sub store_cfg_notification {
my ($self,$dbh,$data)=@_;
my %table=();
my $rv=undef;


	if (! defined $data->{id_device}) {
		if ((defined $data->{name}) || (defined $data->{ip})) {
			$table{id_device}= $self->get_device_id($dbh,$data);
		}
		else { return undef;}
	}
	else {$table{id_device}=$data->{id_device};}
	if (!defined $table{id_device}) {return undef; }

   if (! defined $data->{cause}) { return undef;}
	if ($data->{cause} =~ /\d+/) { $table{id_alert_type}=$data->{cause}; }
	else { $table{id_alert_type}=$self->get_alert_type_id($dbh,$data); }
	if (!defined $table{id_alert_type}) {return undef; }

   if (! defined $data->{notif}) { return undef;}
   if ($data->{notif} =~ /\d+/) { $table{id_notification_type}=$data->{notif}; }
   else { $table{id_notification_type}=$self->get_notification_type_id($dbh,$data); }
   if (!defined $table{id_notification_type}) {return undef; }

	if (! defined $data->{destino}) { return undef;}
	else {$table{destino}=$data->{destino}; }

   if (defined $data->{descr}) {$table{name} = $data->{descr};}
   if (defined $data->{status}) {$table{status} = $data->{status};}

   $rv=sqlInsert($dbh,$TAB_CFG_NOTIFICATIONS_NAME,\%table);
   if (defined $rv) {
      my $rres=sqlSelectAll($dbh,'id_cfg_notification',$TAB_CFG_NOTIFICATIONS_NAME,"id_device=$table{id_device} and id_alert_type=$table{id_alert_type} and id_notification_type=$table{id_notification_type}");
      $self->log('debug',"store_cfg_notification::[DEBUG] Insert cfg_notification [ID=$rres->[0][0]] (RV=$rv)");
      return $rres->[0][0];
   }

	my $rres=sqlSelectAll($dbh,'id_cfg_notification',$TAB_CFG_NOTIFICATIONS_NAME,"id_device=$table{id_device} and id_alert_type=$table{id_alert_type} and id_notification_type=$table{id_notification_type}");
	$table{id_cfg_notification}=$rres->[0][0];

   $rv=sqlUpdate($dbh,$TAB_CFG_NOTIFICATIONS_NAME,\%table,"id_cfg_notification = $table{id_cfg_notification}");
   if (defined $rv) {
      $self->log('debug',"store_cfg_notification::[DEBUG] Update notification $table{descr} [ID=$rres->[0][0]] (RV=$rv)");
      return $table{id_cfg_notification};
   }
   else {
      $self->log('warning',"store_cfg_notification::[WARN] Error en Insert/Update notification $table{descr} (RV=undef)");
   }
   return 0;

}

#----------------------------------------------------------------------------
# Funcion: store_cfg_event2alert
# Descripcion:
#----------------------------------------------------------------------------
sub store_cfg_event2alert {
my ($self,$dbh,$data)=@_;
my %table=();
my $rv=undef;

# | 10.1.254.251   | local7   | 1117: 1w4d: %SYS-5-CONFIG_I: Configured from console by vty0 (10.1.254.201) |
# | NULL           | snmp     | Enterprise Specific Trap (1) Uptime: 497 days, 2:10:13.96, SNMPv2-SMI::enterprises.2854.6.1.1.1 = INTEGER: 1000, SNMPv2-SMI::enterprises.2854.6.1.1.2 = INTEGER: 3, SNMPv2-SMI::enterprises.2854.6.1.1.3 = STRING: \"TlntSvr\", SNMPv2-SMI::enterprises.2854.6. |

	if (! defined $data->{id_dev}) {
		if ((defined $data->{name}) || (defined $data->{ip})) {
			$table{id_dev}= $self->get_device_id($dbh,$data);
		}
		else { $table{id_dev}=0;}
	}

	if (defined $data->{action}) { $table{action}=$data->{action};}
	else { $self->log('warning',"store_cfg_event2alert::[WARN] action=undef"); }

	if (defined $data->{severity}) { $table{severity}=$data->{severity};}
	else { $self->log('warning',"store_cfg_event2alert::[WARN] severity=undef"); }

	if (defined $data->{txt}) { $table{txt}=$data->{txt};}
	else { $self->log('warning',"store_cfg_event2alert::[WARN] txt=undef"); }

   $rv=sqlInsert($dbh,$TAB_CFG_EVENTS2ALERT_NAME,\%table);
   if (defined $rv) {
      my $rres=sqlSelectAll($dbh,'id_cfg_event2alert',$TAB_CFG_EVENTS2ALERT_NAME,"id_dev=$table{id_dev} and txt=\'$table{txt}\'");
      $self->log('debug',"store_cfg_event2alert::[DEBUG] Insert cfg_event2alert [ID=$rres->[0][0]] (RV=$rv)");
      return $rres->[0][0];
   }
	my $rres=sqlSelectAll($dbh,'id_cfg_event2alert',$TAB_CFG_EVENTS2ALERT_NAME,"id_dev=$table{id_dev} and txt=\'$table{txt}\'");

   $table{id_cfg_event2alert}=$rres->[0][0];
   $rv=sqlUpdate($dbh,$TAB_CFG_EVENTS2ALERT_NAME,\%table,"id_cfg_event2alert = $table{id_cfg_event2alert}");
   if (defined $rv) {
      $self->log('debug',"store_cfg_event2alert::[DEBUG] Update event ID_DEV=$table{id_dev} TXT=$table{txt} [ID=$rres->[0][0]] (RV=$rv)");
      return $table{id_cfg_event2alert};
   }
   else {
      $self->log('warning',"store_cfg_event2alert::[WARN] Error en Insert/Update event ID_DEV=$table{id_metric} TXT=$table{txt} (RV=undef)");
   }
   return 0;

}


#----------------------------------------------------------------------------
# get_event
#----------------------------------------------------------------------------
# Obtiene los eventos almacenados en base a las condiciones especificadas.
# id_event = valor  -> Obtiene el evento con id=valor
# id_event = v1,v2,v3 -> Obtiene los eventos con id=v1, v2 y v3.
# Si no se especifica condicion obtiene todos los eventos.
#----------------------------------------------------------------------------
sub get_event {
my ($self,$dbh,$data)=@_;
my %table=();
my $rv=undef;
my $condition='';
my $values="id_event,name,domain,ip,date,code,proccess,msg,msg_custom,evkey,id_dev";
my $tables='events';

   if ( $data->{'id_event'} ) { $condition = 'id_event in ('.$data->{'id_event'}.')'; }

   #my $rres=sqlSelectAll($dbh,$values,$tables,$condition);
   my $rres=sqlSelectHashref($dbh,$values,$tables,$condition);
   return $rres;
}

#----------------------------------------------------------------------------
# Funcion: get_cfg_event2alert
# Descripcion:
# mysql> desc cfg_events2alerts;
# +--------------------+--------------+------+-----+---------+----------------+
# | Field              | Type         | Null | Key | Default | Extra          |
# +--------------------+--------------+------+-----+---------+----------------+
# | id_cfg_event2alert | int(11)      |      | PRI | NULL    | auto_increment |
# | evname             | varchar(255) |      |     |         |                |
# | action             | varchar(255) | YES  |     | NULL    |                |
# | severity           | int(11)      | YES  |     | NULL    |                |
# | type               | varchar(50)  | YES  |     | NULL    |                |
# | subtype            | varchar(50)  | YES  |     | NULL    |                |
# | monitor            | varchar(50)  | YES  |     | NULL    |                |
# +--------------------+--------------+------+-----+---------+----------------+
#
#----------------------------------------------------------------------------
sub get_cfg_event2alert {
my ($self,$dbh,$data)=@_;
my %table=();
my $rv=undef;
my $condition='';
my $values="evname,action,severity,type,subtype,monitor";
my $tables='cfg_events2alerts';


#	if (! defined $data->{id_dev}) {
#		if ((defined $data->{name}) || (defined $data->{ip})) {
#			my $id=$self->get_device_id($dbh,$data);
#			if (defined $id) { $condition = 'id_dev=' . $self->get_device_id($dbh,$data); }
#			else { return undef; }
#		}
#	}
#	elsif ( $data->{id_dev} == 0) { $condition=''; }
#	else { $condition = 'id_dev=' . $data->{id_dev}; }

	if ( $data->{'type'} ) { $condition = "type=\'".$data->{type}."\'"; }

   my $rres=sqlSelectAll($dbh,$values,$tables,$condition);
   return $rres;
}

#----------------------------------------------------------------------------
# Funcion: get_cfg_snmp_remote_alerts
# Descripcion:
# mysql> desc cfg_remote_alerts;
# +-----------------+--------------+------+-----+---------+----------------+
# | Field           | Type         | Null | Key | Default | Extra          |
# +-----------------+--------------+------+-----+---------+----------------+
# | id_remote_alert | int(11)      |      | PRI | NULL    | auto_increment |
# | target          | varchar(50)  |      |     | *       |                |
# | type            | varchar(50)  |      |     |         |                |
# | subtype         | varchar(50)  |      |     |         |                |
# | monitor         | varchar(50)  |      |     |         |                |
# | vdata           | varchar(100) |      |     |         |                |
# | severity        | int(11)      |      |     | 1       |                |
# | action          | varchar(20)  |      |     |         |                |
# | script          | varchar(255) |      |     |         |                |
# | expr            | varchar(200) | NO   |     |         |                |
# | mode            | varchar(20)  | NO   |     | INC     |                |
# +-----------------+--------------+------+-----+---------+----------------+
#
#----------------------------------------------------------------------------
sub get_cfg_snmp_remote_alerts {
my ($self,$dbh)=@_;
my %table=();
my $rv=undef;
my $values="a.subtype,b.target,a.monitor,a.vdata,a.action,a.severity,a.script,a.descr,a.id_remote_alert,a.expr,a.mode,a.set_id,a.set_type,a.set_subtype,a.set_hiid,a.vdata";
my $tables='cfg_remote_alerts a, cfg_remote_alerts2device b';
my $condition="a.id_remote_alert=b.id_remote_alert and a.type='snmp'";


   my $rres=sqlSelectAll($dbh,$values,$tables,$condition);
   $self->error($libSQL::err);
   $self->errorstr($libSQL::errstr);
   $self->lastcmd($libSQL::cmd);

   my %trap2alert=();
   my %trap2alert_patterns=();
   foreach my $i (@$rres) {

      my $ev=$i->[0];
      if ($i->[0] =~ /^\d+_(\S+)$/) { $ev=$1; }

		# Unificacion traps v1/v2
		if ($ev=~/\S+\:6\.(\S+)/) { $ev=$1; }
		if ($ev=~/CPQHOST-MIB::compaq\.6\.(\S+)/) { $ev=$1; } #ERROR legacy !!!

      # Uso de comodines ==> Se trata de TRAP2ALERT_PATTERNS
      if ($ev =~ /(\S+)\*/) {
         if ( ref ($trap2alert_patterns{$ev}) eq "ARRAY") {
            push @{$trap2alert_patterns{$ev}}, {'subtype'=>$i->[0], 'target'=>$i->[1], 'monitor'=>$i->[2], 'vdata'=>$i->[3],  'action'=>$i->[4], 'severity'=>$i->[5], 'script'=>$i->[6], 'descr'=>$i->[7], 'id_remote_alert'=>$i->[8], 'expr'=>$i->[9], 'mode'=>$i->[10], 'set_id'=>$i->[11], 'set_type'=>$i->[12], 'set_subtype'=>$i->[13], 'set_hiid'=>$i->[14], 'vdata'=>$i->[15]};
         }
         else {
            $trap2alert_patterns{$ev} = [ {'subtype'=>$i->[0], 'target'=>$i->[1], 'monitor'=>$i->[2], 'vdata'=>$i->[3], 'action'=>$i->[4], 'severity'=>$i->[5], 'script'=>$i->[6], 'descr'=>$i->[7], 'id_remote_alert'=>$i->[8], 'expr'=>$i->[9], 'mode'=>$i->[10], 'set_id'=>$i->[11], 'set_type'=>$i->[12], 'set_subtype'=>$i->[13], 'set_hiid'=>$i->[14], 'vdata'=>$i->[15] } ];
         }
      }
      # Sin comodinas ==> Se trata de TRAP2ALERT
      else {
         if ( ref ($trap2alert{$ev}) eq "ARRAY") {
            push @{$trap2alert{$ev}}, {'subtype'=>$i->[0], 'target'=>$i->[1], 'monitor'=>$i->[2], 'vdata'=>$i->[3], 'action'=>$i->[4], 'severity'=>$i->[5], 'script'=>$i->[6], 'descr'=>$i->[7], 'id_remote_alert'=>$i->[8], 'expr'=>$i->[9], 'mode'=>$i->[10], 'set_id'=>$i->[11], 'set_type'=>$i->[12], 'set_subtype'=>$i->[13], 'set_hiid'=>$i->[14], 'vdata'=>$i->[15] };
         }
         else {
            $trap2alert{$ev} = [ {'subtype'=>$i->[0], 'target'=>$i->[1], 'monitor'=>$i->[2], 'vdata'=>$i->[3], 'action'=>$i->[4], 'severity'=>$i->[5], 'script'=>$i->[6], 'descr'=>$i->[7], 'id_remote_alert'=>$i->[8], 'expr'=>$i->[9], 'mode'=>$i->[10], 'set_id'=>$i->[11], 'set_type'=>$i->[12], 'set_subtype'=>$i->[13], 'set_hiid'=>$i->[14], 'vdata'=>$i->[15] } ];
         }
      }

   }

   return (\%trap2alert, \%trap2alert_patterns);


}


#----------------------------------------------------------------------------
# get_cfg_email_remote_alerts
# Devuelve un hash inexado por subtype de alerta remota (mail_00000028...) de tipo mail
# Con las definidas y asociadas a algun dispositivo
#----------------------------------------------------------------------------
sub get_cfg_email_remote_alerts {
my ($self,$dbh)=@_;
my %table=();
my $rv=undef;
my $values="a.subtype,b.target,a.monitor,a.vdata,a.action,a.severity,a.script,a.descr,a.id_remote_alert,a.expr,a.mode,d.email,d.name,a.hiid,a.set_id,a.set_type,a.set_subtype,a.set_hiid";
my $tables='cfg_remote_alerts a, cfg_remote_alerts2device b, devices d';
my $condition="a.id_remote_alert=b.id_remote_alert and b.target=d.ip and a.type='email'";


   my $rres=sqlSelectAll($dbh,$values,$tables,$condition);
   $self->error($libSQL::err);
   $self->errorstr($libSQL::errstr);
   $self->lastcmd($libSQL::cmd);

	my %email2alert=();
	foreach my $i (@$rres) {
	
		my $ev=$i->[0]; #mail_00000029 ...
		my $email=$i->[11];
		my $name = uc $i->[12];
		my $hiid=$i->[13];

		my $key=$ev.':'.$hiid;
		$email2alert{$key}->{$name} = {'subtype'=>$i->[0], 'target'=>$i->[1], 'monitor'=>$i->[2], 'vdata'=>$i->[3], 'action'=>$i->[4], 'severity'=>$i->[5], 'script'=>$i->[6], 'descr'=>$i->[7], 'id_remote_alert'=>$i->[8], 'expr'=>$i->[9], 'mode'=>$i->[10], 'email'=>$i->[11], 'name'=>$name, 'set_id'=>$i->[14], 'set_type'=>$i->[15], 'set_subtype'=>$i->[16], 'set_hiid'=>$i->[17] };	

	}

   return \%email2alert;
}

#----------------------------------------------------------------------------
# get_cfg_syslog_remote_alerts
# Devuelve un hash inexado por subtype de alerta remota (log_00000028...) de tipo syslog
# Con las definidas y asociadas a algun dispositivo
#----------------------------------------------------------------------------
sub get_cfg_syslog_remote_alerts {
my ($self,$dbh)=@_;
my %table=();
my $rv=undef;
my $values="a.subtype,b.target,a.monitor,a.vdata,a.action,a.severity,a.script,a.descr,a.id_remote_alert,a.expr,a.mode,d.ip,d.name,d.domain,a.set_id,a.set_type,a.set_subtype,a.set_hiid";
my $tables='cfg_remote_alerts a, cfg_remote_alerts2device b, devices d';
my $condition="a.id_remote_alert=b.id_remote_alert and b.target=d.ip and a.type='syslog'";


   my $rres=sqlSelectAll($dbh,$values,$tables,$condition);
   $self->error($libSQL::err);
   $self->errorstr($libSQL::errstr);
   $self->lastcmd($libSQL::cmd);

   if ($libSQL::err) {
      $self->manage_db_error($dbh,"get_cfg_syslog_remote_alerts ($libSQL::errstr)");
   }

   my %syslog2alert=();
   foreach my $i (@$rres) {

      my $ev=$i->[0]; #mail_00000029 ...
		my $ip=$i->[11];

      $syslog2alert{$ev}->{$ip} = {'subtype'=>$i->[0], 'target'=>$i->[1], 'monitor'=>$i->[2], 'vdata'=>$i->[3], 'action'=>$i->[4], 'severity'=>$i->[5], 'script'=>$i->[6], 'descr'=>$i->[7], 'id_remote_alert'=>$i->[8], 'expr'=>$i->[9], 'mode'=>$i->[10], 'ip'=>$i->[11], 'name'=>$i->[12], 'domain'=>$i->[13], 'set_id'=>$i->[14], 'set_type'=>$i->[15], 'set_subtype'=>$i->[16], 'set_hiid'=>$i->[17] };

   }

   return \%syslog2alert;
}

#----------------------------------------------------------------------------
# get_cfg_api_remote_alerts
# Devuelve un hash inexado por subtype de alerta remota () de tipo API
# Con las definidas y asociadas a algun dispositivo
#----------------------------------------------------------------------------
sub get_cfg_api_remote_alerts {
my ($self,$dbh)=@_;
my %table=();
my $rv=undef;
my $values="a.subtype,b.target,a.monitor,a.vdata,a.action,a.severity,a.script,a.descr,a.id_remote_alert,a.expr,a.mode,d.ip,d.name,d.domain,a.hiid,a.set_id,a.set_type,a.set_subtype,a.set_hiid";
my $tables='cfg_remote_alerts a, cfg_remote_alerts2device b, devices d';
my $condition="a.id_remote_alert=b.id_remote_alert and b.target=d.ip and a.type='api'";


   my $rres=sqlSelectAll($dbh,$values,$tables,$condition);
   $self->error($libSQL::err);
   $self->errorstr($libSQL::errstr);
   $self->lastcmd($libSQL::cmd);

   my %api2alert=();
   foreach my $i (@$rres) {

      my $ev=$i->[0]; #evkey ...
		my $hiid=$i->[14];
      my $ip=$i->[11];

		push @{$api2alert{$ev}->{$ip}}, {'subtype'=>$i->[0], 'target'=>$i->[1], 'monitor'=>$i->[2], 'vdata'=>$i->[3], 'action'=>$i->[4], 'severity'=>$i->[5], 'script'=>$i->[6], 'descr'=>$i->[7], 'id_remote_alert'=>$i->[8], 'expr'=>$i->[9], 'mode'=>$i->[10], 'ip'=>$i->[11], 'name'=>$i->[12], 'domain'=>$i->[13], 'set_id'=>$i->[15], 'set_type'=>$i->[16], 'set_subtype'=>$i->[17], 'set_hiid'=>$i->[18] };
 		
#      $api2alert{$ev}->{$ip} = {'subtype'=>$i->[0], 'target'=>$i->[1], 'monitor'=>$i->[2], 'vdata'=>$i->[3], 'action'=>$i->[4], 'severity'=>$i->[5], 'script'=>$i->[6], 'descr'=>$i->[7], 'id_remote_alert'=>$i->[8], 'expr'=>$i->[9], 'mode'=>$i->[10], 'ip'=>$i->[11], 'name'=>$i->[12], 'domain'=>$i->[13], 'set_id'=>$i->[15], 'set_type'=>$i->[16], 'set_subtype'=>$i->[17], 'set_hiid'=>$i->[18] };

   }

   return \%api2alert;
}

#----------------------------------------------------------------------------
# get_cfg_syslog_acls
# Devuelve un hash indexado por ip de los logs configurados para recepcion. (logr)
# Para el caso logp ya se contempla en la query inicial.
#----------------------------------------------------------------------------
sub get_cfg_syslog_acls {
my ($self,$dbh)=@_;
my %table=();
my $rv=undef;
my $values="l.logfile,d.ip";
my $tables='device2log l, devices d';
my $condition="l.id_dev=d.id_dev and l.status=0 and l.logfile IN ('syslog-local2','syslog-local3','syslog-local4','syslog-filters')";
# Realmente la condicion seria con el tipo de credencial (tabla credentials), pero como coincide con logfile nos evitamos cruzar con otra tabla.

   my $rres=sqlSelectAll($dbh,$values,$tables,$condition);
   $self->error($libSQL::err);
   $self->errorstr($libSQL::errstr);
   $self->lastcmd($libSQL::cmd);

   my %acls=();
   foreach my $i (@$rres) {
		# ip.logfile (ip.syslog-local2, ip.syslog-local3 ...)
		my $key=$i->[1].'.'.$i->[0];
		$acls{$key} = 1;
   }

   return \%acls;
}

#----------------------------------------------------------------------------
# get_all_stored_device_ips
# Obtiene el resto de IPs de un dispositivo almacenadas en kb_interfaces.
# Devuelve un hash con el mapeo ifIP -> host_ip (ip dada de alta)
#----------------------------------------------------------------------------
sub get_all_stored_device_ips {
my ($self,$dbh)=@_;
my %table=();
my $rv=undef;
my $values="host_ip,ifIp";
my $tables='kb_interfaces';
my $condition="ifIp !=''";

   my $rres=sqlSelectAll($dbh,$values,$tables,$condition);
   $self->error($libSQL::err);
   $self->errorstr($libSQL::errstr);
   $self->lastcmd($libSQL::cmd);

   my %all_ips=();
   foreach my $i (@$rres) {
      # ip.logfile (ip.syslog-local2, ip.syslog-local3 ...)
      my $host_ip=$i->[0];
      my $ifIp=$i->[1];
		if ($ifIp eq '127.0.0.1') { next; } 
      if (exists $all_ips{$ifIp}) {
         $self->log('warning',"get_all_stored_device_ips::[WARN] EXISTE $ifIp -> $all_ips{$ifIp} (host_ip=$host_ip)");
      }
      $all_ips{$ifIp} = $host_ip;
   }

	$all_ips{'127.0.0.1'} = $self->cid_ip();
   return \%all_ips;
}


#----------------------------------------------------------------------------
# Funcion: get_cfg_snmp_remote_alerts_trap_expr
# Descripcion:
#
# SELECT a.id_remote_alert,a.expr as expr_logic, b.v,b.descr,b.fx,b.expr FROM cfg_remote_alerts a, cfg_remote_alerts2expr b WHERE a.id_remote_alert=b.id_remote_alert and a.type='snmp';
#----------------------------------------------------------------------------
sub get_cfg_snmp_remote_alerts_trap_expr {
my ($self,$dbh)=@_;
my %table=();
my $rv=undef;

my $values="a.id_remote_alert,a.expr as expr_logic, b.v,b.descr,b.fx,b.expr";
my $tables='cfg_remote_alerts a, cfg_remote_alerts2expr b';
my $condition="a.id_remote_alert=b.id_remote_alert and a.type='snmp' and b.expr !=''";


   my $rres=sqlSelectAll($dbh,$values,$tables,$condition);
   $self->error($libSQL::err);
   $self->errorstr($libSQL::errstr);
   $self->lastcmd($libSQL::cmd);

   return $rres;
}


#----------------------------------------------------------------------------
# Funcion: get_remote_alert_expr_by_type
# Descripcion:
# Obtiene un hash con las expresiones definidas para cada alerta remota de tipo
# email, que se deben cumplir para generar una alerta.
# $type es 'email' o 'snmp'
# select a.id_remote_alert,a.v,a.descr,a.fx,a.expr from cfg_remote_alerts2expr a, cfg_remote_alerts b where a.id_remote_alert=b.id_remote_alert and b.type='email';
#----------------------------------------------------------------------------
sub get_remote_alert_expr_by_type {
my ($self,$dbh,$type)=@_;


   my $rres=sqlSelectAll(  $dbh,
                           'a.id_remote_alert,a.expr as expr_logic,b.v,b.descr,b.fx,b.expr',
                           'cfg_remote_alerts a, cfg_remote_alerts2expr b',
                           "a.id_remote_alert=b.id_remote_alert and a.type=\'$type\' and b.expr !=''");

   $self->error($libSQL::err);
   $self->errorstr($libSQL::errstr);
   $self->lastcmd($libSQL::cmd);


   my %alert2expr=();
   foreach my $i (@$rres) {
      #a.id_remote_alert,a.expr as expr_logic, b.v,b.descr,b.fx,b.expr
      # La clave es el a.id_remote_alert

      my $id_remote_alert=$i->[0];
      if ( ref ($alert2expr{$id_remote_alert}) eq "ARRAY") {
         push @{$alert2expr{$id_remote_alert}}, {'expr_logic'=>$i->[1], 'v'=>$i->[2], 'descr'=>$i->[3],  'fx'=>$i->[4], 'expr'=>$i->[5]};
      }
      else {
         $alert2expr{$id_remote_alert} = [ {'expr_logic'=>$i->[1], 'v'=>$i->[2], 'descr'=>$i->[3],  'fx'=>$i->[4], 'expr'=>$i->[5]} ];
      }
   }

	return \%alert2expr;

}


#----------------------------------------------------------------------------
sub sp_delete_remote_class  {
my ($self,$dbh,$class)=@_;

   my $rv=sqlCmd($dbh,"CALL sp_delete_remote_class(\'$class\')");

   $self->error($libSQL::err);
   $self->errorstr($libSQL::errstr);
   $self->lastcmd($libSQL::cmd);
   if ($libSQL::err) {
      $self->manage_db_error($dbh,"sp_delete_remote_class ($libSQL::errstr)");
   }
}

#----------------------------------------------------------------------------
# Funcion: get_cfg_events_data
# Descripcion:
# mysql> desc cfg_events_data;
# +--------------------+--------------+------+-----+---------+----------------+
# | Field              | Type         | Null | Key | Default | Extra          |
# +--------------------+--------------+------+-----+---------+----------------+
# | id_cfg_events_data | int(11)      |      | MUL | NULL    | auto_increment |
# | process            | varchar(50)  |      | PRI |         |                |
# | evkey              | varchar(100) |      | PRI |         |                |
# | txt_custom         | text         |      |     |         |                |
# +--------------------+--------------+------+-----+---------+----------------+
#
#----------------------------------------------------------------------------
sub get_cfg_events_data {
my ($self,$dbh)=@_;
my %table=();
my $rv=undef;
my $values='evkey,txt_custom';
my $tables='cfg_events_data';
my $condition="process = 'TRAP-SNMP'";


   my $rres=sqlSelectAll($dbh,$values,$tables,$condition);
   $self->error($libSQL::err);
   $self->errorstr($libSQL::errstr);
   $self->lastcmd($libSQL::cmd);

   my %event2data=();
   foreach my $i (@$rres) {
      # evkey,txt_custom
      # La clave es el evkey

      $event2data{$i->[0]} = $i->[1];
      #$self->log('info',"get_cfg_events_data::[DEBUG] EVENT MAPPED evkey=$i->[0]: txt_custom=$i->[1]");
   }

	return \%event2data;
}


#----------------------------------------------------------------------------
# Funcion: update_service
# Descripcion:
#----------------------------------------------------------------------------
sub update_service {
my ($self,$dbh,$data)=@_;
my %table=();
my $rv=undef;

   if (defined $data->{id_serv}) { $table{id_serv}=$data->{id_serv}; }
   else {return;}

   if (defined $data->{level}) {$table{level}=$data->{level};}
   if (defined $data->{name}) {$table{name}= lc $data->{name};}
   if (defined $data->{description}) {$table{description}= lc $data->{description};}
   if (defined $data->{type}) {$table{type}= lc $data->{type};}

   $rv=sqlUpdate($dbh,$TAB_SERVICES_NAME,\%table,"id_serv=$table{id_serv}");
   if (defined $rv) {
      $self->log('debug',"update_service::[DEBUG] Update service $table{id_serv} (RV=$rv)");
   }
   else {
      $self->log('warning',"update_service::[WARN] Error en Update service $table{id_serv} (RV=undef)");
   }
   return $rv;

}

#----------------------------------------------------------------------------
# Funcion: store_metric2snmp
# Descripcion:
#----------------------------------------------------------------------------
sub store_metric2snmp {
my ($self,$dbh,$data)=@_;
my %table=();
my $rv=undef;

	#id_dev (Id. de dispositivo), name (Nombre de metrica)
   if ( (defined $data->{id_dev}) && (defined $data->{name}))	{$table{id_metric}= $self->get_metric_id($dbh,$data);}
	else {
      $self->log('warning',"store_metric2snmp::[WARN] id_metric=undef");
		return;
	}

   if (defined $data->{community}) {$table{community}= $data->{community};}
	else {
	 	$self->log('warning',"store_metric2snmp::[WARN] community=undef");
		return;
	}
	
	if (defined $data->{oid}) {$table{oid}= $data->{oid};}
	else {
	 	$self->log('warning',"store_metric2snmp::[WARN] oid=undef");
		return;
	}

	$table{version}=(defined $data->{version}) ? $data->{version} : '2';
	if (defined $data->{params}) {$table{params}= $data->{params};}

	#Hago un delete y un Insert. En este caso no me interesa la historia porque es una tabla auxiliar y cada metrica snmp solo tiene que tener una entrada en la tabla.
   sqlDelete($dbh,$TAB_METRIC2SNMP_NAME,"id_metric=\'$table{id_metric}\'");

   $rv=sqlInsert($dbh,$TAB_METRIC2SNMP_NAME,\%table);
   $self->error($libSQL::err);
   $self->errorstr($libSQL::errstr);
   $self->lastcmd($libSQL::cmd);

   if (defined $rv) {
      $self->log('debug',"store_metric2snmp::[DEBUG] Insert $table{id_metric}:$table{community}:$table{oid} (RV=$rv)");
   	return 0;
   }
   #$rv=sqlUpdate($dbh,$TAB_METRIC2SNMP_NAME,\%table,"id_metric=\'$table{id_metric}\' && oid=\'$table{oid}\'");
   #if (defined $rv) {
   #   $self->log('debug',"store_metric2snmp::[DEBUG] Update $table{id_metric}:$table{community}:$table{oid} (RV=$rv)");
   #	return 0;
   #}

   else {
      $self->log('warning',"store_metric2snmp::[WARN] Error en Insert $table{id_metric}:$table{community}:$table{oid} (RV=undef)");
   }
   return 0;

}


#----------------------------------------------------------------------------
# Funcion: store_metric2latency
# Descripcion:
#----------------------------------------------------------------------------
sub store_metric2latency {
my ($self,$dbh,$data)=@_;
my %table=();
my $rv=undef;

	if ((defined $data->{id_dev}) && (defined $data->{name}))	{$table{id_metric}= $self->get_metric_id($dbh,$data);}
	else {
      $self->log('warning',"store_metric2latency::[WARN] id_metric=undef");
		return;
	}

   if (defined $data->{monitor}) {$table{monitor}= $data->{monitor};}
	else {
	 	$self->log('warning',"store_metric2latency::[WARN] monitor=undef");
		return;
	}
	
	if (defined $data->{monitor_data}) {$table{monitor_data}= $data->{monitor_data};}

   #Hago un delete y un Insert. En este caso no me interesa la historia porque es una tabla auxiliar y cada metrica latency solo tiene que tener una entrada en la tabla.
   sqlDelete($dbh,$TAB_METRIC2LATENCY_NAME,"id_metric=\'$table{id_metric}\'");
	
	$rv=sqlInsert($dbh,$TAB_METRIC2LATENCY_NAME,\%table);
   $self->error($libSQL::err);
   $self->errorstr($libSQL::errstr);
   $self->lastcmd($libSQL::cmd);

   if (defined $rv) {
      $self->log('debug',"store_metric2latency::[DEBUG] Insert $data->{id_dev}:$table{monitor} (RV=$rv)");
   	return 0;
   }
   #$rv=sqlUpdate($dbh,$TAB_METRIC2LATENCY_NAME,\%table,"id_metric=\'$table{id_metric}\' && monitor=\'$table{monitor}\'");
   #if (defined $rv) {
   #   $self->log('debug',"store_metric2latency::[DEBUG] Update $table{id_metric}:$table{monitor} (RV=$rv)");
   #	return 0;
   #}

   else {
      $self->log('warning',"store_metric2latency::[WARN] Error en Insert/Update $table{id_metric}:$table{monitor} (RV=undef)");
   }
   return 0;

}


#----------------------------------------------------------------------------
# Funcion: store_metric2agent
# Descripcion:
#----------------------------------------------------------------------------
sub store_metric2agent {
my ($self,$dbh,$data)=@_;
my %table=();
my $rv=undef;

   if (defined $data->{id_metric})   {$table{id_metric}=$data->{id_metric}; }
   elsif ((defined $data->{id_dev}) && (defined $data->{name}))   {$table{id_metric}= $self->get_metric_id($dbh,$data);}
   else {
      $self->log('warning',"store_metric2agent::[WARN] id_metric=undef");
      return;
   }

   if (defined $data->{monitor}) {$table{monitor}= $data->{monitor};}
   else {
      $self->log('warning',"store_metric2agent::[WARN] monitor=undef");
      return;
   }

   if (defined $data->{monitor_data}) {$table{monitor_data}= $data->{monitor_data};}

   #Hago un delete y un Insert. En este caso no me interesa la historia porque es una tabla auxiliar y cada metrica latency solo tiene que tener una entrada en la tabla.
   sqlDelete($dbh,$TAB_METRIC2AGENT_NAME,"id_metric=\'$table{id_metric}\'");

   $rv=sqlInsert($dbh,$TAB_METRIC2AGENT_NAME,\%table);
   $self->error($libSQL::err);
   $self->errorstr($libSQL::errstr);
   $self->lastcmd($libSQL::cmd);

   if (defined $rv) {
      $self->log('debug',"store_metric2agent::[DEBUG] Insert $data->{id_dev}:$table{monitor} (RV=$rv)");
      return 0;
   }

   else {
      $self->log('warning',"store_metric2agent::[WARN] Error en Insert/Update $table{id_metric}:$table{monitor} (RV=undef)");
   }
   return 0;

}


#----------------------------------------------------------------------------
# Funcion: round_time
# Descripcion: Redondea un timestamp
# $ts -> timestamp de entrada
# $n	-> Periodo de redondeo en segundos. (60=>1 minuto, 3600=> 1 hora)
# Out:
# $ts ya redondeado
#----------------------------------------------------------------------------
sub round_time {
my ($self,$ts,$n)=@_;

   my $resto=$ts % $n;
   my $suma=0;
   if ($resto<$n/2) {$suma=-$resto;}
   else {$suma=$n-$resto;}
   return $ts+$suma;
}

#----------------------------------------------------------------------------
# Funcion: truncate_time
# Descripcion: Trunca un timestamp
# $ts -> timestamp de entrada
# $n  -> Periodo de trunc en segundos. (60=>1 minuto, 3600=> 1 hora)
# Out:
# $ts ya truncado
#----------------------------------------------------------------------------
sub truncate_time {
my ($self,$ts,$n)=@_;

   my $resto=$ts % $n;
   return $ts-$resto;
}


#----------------------------------------------------------------------------
sub get_raw_tables{
my ($self,$dbh)=@_;

   my $rres=sqlTableExists($dbh,'__raw__%');
   my @data=();
   foreach my $l (@$rres) {
      push @data, $l->[0];
   }
   return \@data;
}


#----------------------------------------------------------------------------
sub get_distinct_devices_in_table{
my ($self,$dbh,$table)=@_;

   my $rres=sqlSelectAll($dbh, 'distinct id_dev', $table);
   my @data=();
   foreach my $l (@$rres) {
      push @data, $l->[0];
   }
   return \@data;
}

#----------------------------------------------------------------------------
# get_graph_subtables_vector
#----------------------------------------------------------------------------
# Obtiene el vector que mapea $id_dev-$subtype-$iid a subtabla
# select distinct subtype,subtable,count(*) as cuantos  from metrics where subtable>0 group by subtype,subtable order by cuantos;
   #+--------------+----------+---------+
   #| subtype      | subtable | cuantos |
   #+--------------+----------+---------+
   #| disk_mibhost |        1 |      27 |
   #+--------------+----------+---------+
# Obtiene el vector de metricas con subtable>1
sub get_graph_subtables_vector {
my ($self,$dbh)=@_;

	my %vector=();
   my $rres=sqlSelectAll($dbh, 'id_dev,subtype,iid,subtable', 'metrics', 'subtable>0','order by subtype,subtable');

   $self->error($libSQL::err);
   $self->errorstr($libSQL::errstr);
   $self->lastcmd($libSQL::cmd);

   if ($libSQL::err) {
      #$self->log('warning',"get_graph_subtables_vector::[ERROR] (EDB=$libSQL::err) $libSQL::errstr ($libSQL::cmd)");
		$self->manage_db_error($dbh,"get_graph_subtables_vector");
   }

   foreach my $l (@$rres) {
      my ($id_dev,$subtype,$iid,$subtable) = ($l->[0], $l->[1], $l->[2], $l->[3]);
		my $key="$id_dev-$subtype-$iid";
		$vector{$key}=$subtable;
	}

	return \%vector;
}


#----------------------------------------------------------------------------
# select subtype,subtable,count(*) as c from metrics group by subtype,subtable order by c;
sub set_graph_subtables {
my ($self,$dbh)=@_;

my $MAX_METRICS_PER_SUBTABLE=1000;

   my $rres=sqlSelectAll($dbh, 'subtype,subtable,count(*) as c', 'metrics', '','group by subtype,subtable order by c');
   my %empty=();
   my %assigned=();
   foreach my $l (@$rres) {

		#+--------------------------------+----------+----+
		#| subtype                        | subtable | c  |
		#+--------------------------------+----------+----+
		#| w_mon_tcp-543747f5             |       -1 |  1 |
		#| custom_6b74c89e                |       -1 |  1 |

		my ($subtype,$subtable,$c) = ($l->[0], $l->[1], $l->[2]);
		if ($subtable==-1) { $empty{$subtype} = {'subtable'=>$subtable, 'c'=>$c}; }
		else {
			my $left=$MAX_METRICS_PER_SUBTABLE-$c;
			if (! exists $assigned{$subtype}) { $assigned{$subtype} = [{'subtable'=>$subtable, 'c'=>$c, 'left'=>$left}]; }
			else { push @{$assigned{$subtype}}, {'subtable'=>$subtable, 'c'=>$c, 'left'=>$left}; }
		}
	}

	#Metricas no inicializadas
	foreach my $subtype (keys %empty) {
	
		my $n=0;
		if (exists $assigned{$subtype}) { $n=scalar(@{$assigned{$subtype}});	}
		my $next_subtable=$n;

		$self->log('debug',"set_graph_subtables:: NO INICIALIZADO subtype=$subtype (asignadas N=$n next=$next_subtable)");

		#select id_metric from metrics where subtype='proc_cnt_mibhost' and subtable=-1 order by id_dev;
		$rres=sqlSelectAll($dbh, 'id_metric', 'metrics', "subtype=\'$subtype\' and subtable=-1",'order by id_dev');
		foreach my $l (@$rres) {
			my $done=0;
			my $id_metric=$l->[0];
			for my $i (0..$n-1) {

				if ($assigned{$subtype}->[$i]->{'left'}>0) {
		
					#Actualizao subtable de la metrica correspondiente
      			my $rv=sqlUpdate($dbh,'metrics',{'subtable'=>$i},"id_metric=$id_metric");
				   $self->error($libSQL::err);
   				$self->errorstr($libSQL::errstr);
   				$self->lastcmd($libSQL::cmd);

					$self->log('debug',"set_graph_subtables:: subtype=$subtype METRICA=$id_metric HUECO en subtable=$i (rv=$rv)");
					if ($libSQL::err) {	
						#$self->log('warn',"set_graph_subtables:: **DB_ERROR** err=$libSQL::err) errstr=$libSQL::errstr sql=$libSQL::cmd");
						$self->manage_db_error($dbh,"set_graph_subtables0");
					}
					$done=1;
					$assigned{$subtype}->[$i]->{'left'} -= 1;	
				}
			}
			if (!$done) {
				if (! exists $assigned{$subtype}) { $assigned{$subtype} = [{'subtable'=>$next_subtable, 'c'=>0, 'left'=>$MAX_METRICS_PER_SUBTABLE}]; }
				else { push @{$assigned{$subtype}}, {'subtable'=>$next_subtable, 'c'=>0, 'left'=>$MAX_METRICS_PER_SUBTABLE}; }

            #Actualizao subtable de la metrica correspondiente
            my $rv=sqlUpdate($dbh,'metrics',{'subtable'=>$next_subtable},"id_metric=$id_metric");
            $self->error($libSQL::err);
            $self->errorstr($libSQL::errstr);
            $self->lastcmd($libSQL::cmd);

				$self->log('debug',"set_graph_subtables:: subtype=$subtype METRICA=$id_metric NUEVA subtable=$next_subtable (rv=$rv)");
            if ($libSQL::err) {
               #$self->log('warn',"set_graph_subtables:: **DB_ERROR** err=$libSQL::err) errstr=$libSQL::errstr sql=$libSQL::cmd");
					$self->manage_db_error($dbh,"set_graph_subtables1");
            }

				$n+=1;
				$assigned{$subtype}->[$next_subtable]->{'left'} -= 1;
				$next_subtable +=1;
			}
		}
  	}

   return;
}

#----------------------------------------------------------------------------
# Funcion: load_store_graph_data
# Descripcion:
# $subtype -> Es el subtipo de la metrica
# Los datos se almacenan en una tabla con el prefijo _raw_ (p.ej _dest_mon_icmp)
# $data -> ts:v1:v2 .....:vn

# Para  raw:
#              H1                   Cada 5min/1min (12/60 valores)
#+--------+------------+------+-----------------------------------------+-----------+----------+----------+
#| id_dev | ts_line    | hiid | v1                                      | v1avg     | v1max    | v1min    |
#+--------+------------+------+-----------------------------------------+-----------+----------+----------+
#|     31 | 1283590800 | ALL  | 1283591040:0.004003;..;3591340:0.024232 | 0.0177257 | 0.035816 |  0.00391 |

# Para store:
#              D1
#+--------+------------+------+----+-----------+----------+---------+
#| id_dev | ts_line    | hiid | v1 | v1avg     | v1max    | v1min   |
#+--------+------------+------+----+-----------+----------+---------+
#|     31 | 1283464800 | ALL  |    | 0.0200005 | 0.295585 | 0.00308 |
#+--------+------------+------+----+-----------+----------+---------+
#
sub load_store_graph_data {
my ($self,$dbh,$id_dev_vector,$table_source)=@_;


   #__raw__000__1__latency__w_mon_dns_e26ca9da
   my ($mode,$subtable,$nitems,$type,$subtype);
   if ($table_source =~ /__(\w+)__(\w+)__(\w+)__(\w+)__(\w+)/) {
      ($mode,$subtable,$nitems,$type,$subtype) = ($1,$2,$3,$4,$5);
   }
   else { #error termino
      $self->log('warning',"load_store_graph_data::**ERR** No se puede consolidar la tabla $table_source (formato incorrecto)");
      return;
   }

   # ------------------------------------------------------
   # Selecciona el vector de datos de la tabla origen que hay que consolidar
   # y prepara campos variables para el insert con placeholders
   my @fields_select=();
   my @names=('id_dev','ts_line','hiid');
   my @values=('?','?','?');
	my @sets=('id_dev=?','ts_line=?','hiid=?');
   foreach my $i (1..$nitems) {
      my $k1="v$i".'avg';
      my $k2="v$i".'max';
      my $k3="v$i".'min';
      push @fields_select, $k1,$k2,$k3;
      push @names, $k1,$k2,$k3;
      push @values, '?','?','?';
		push @sets, "$k1=?","$k3=?","$k2=?";
      $i+=1;
   }

   # ------------------------------------------------------
   my $tnow=time;
	my $tlimit_raw=$tnow-2851200; #33 dias
	my $tlimit_store=$tnow-71280000; #33 dias * 25 (>2years)
   my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime $tnow;
   my $table_dest='__store__'.$subtable.'__'.$nitems.'__'.$type.'__'.$subtype;
   my $ttl = timelocal(0,0,0,$mday,$mon,$year);

   # ---------------------------------------------------------------------
   # Valida que exista la tabla destino, en caso contrario, la crea
   # ---------------------------------------------------------------------
   my $rres=sqlTableExists($dbh,$table_dest);
   if ($rres->[0][0] ne $table_dest) {

      #sqlCreateLike($dbh,$table_dest,$table_source);
		$self->prepare_graph_data_compact_block($dbh,$table_source,'');

#      $self->error($libSQL::err);
#      $self->errorstr($libSQL::errstr);
#      $self->lastcmd($libSQL::cmd);
#      $self->log('info',"load_store_graph_data::[INFO] CREADA TABLA $table_dest ($libSQL::err $libSQL::errstr) (CMD=$libSQL::cmd)");

   }


   # ---------------------------------------------------------------------
   # Si no se ha especificado un vector de dispositivos, la consolidacion se aplica a
   # todos los dispositivos  existentes.
   if (scalar(@$id_dev_vector)==0) {
      $id_dev_vector=$self->get_distinct_devices_in_table($dbh, $table_source);
   }
   # ---------------------------------------------------------------------

   # ---------------------------------------------------------------------
   # Recorro los diferentes dispositivos a procesar
   # ---------------------------------------------------------------------
   foreach my $id_dev (@$id_dev_vector) {
	
      # ----------------------------------------------------------------------
      # Obtengo el rango de dias a consolidar para este dispositivo
      # ----------------------------------------------------------------------
      # SELECT  distinct dayofmonth(from_unixtime(ts_line)) as days, unix_timestamp(makedate(2010,dayofyear(from_unixtime(ts_line)))) as ts_item from __raw__000__1__latency__mon_icmp where id_dev=31 and ts_line < 1283594400 order by ts_line;
      #  +------+------------+
      #  | days | ts_item    |
      #  +------+------------+
      #  |    3 | 1283464800 |
      #  |    4 | 1283551200 |
      #  +------+------------+
      # ----------------------------------------------------------------------
      my $days_range=sqlSelectAll($dbh,
                           'distinct dayofmonth(from_unixtime(ts_line)) as days, unix_timestamp(makedate(2010,dayofyear(from_unixtime(ts_line)))) as ts_item',
                           $table_source,
                           "id_dev=$id_dev and ts_line < $ttl",
                           'order by ts_line' );

      my $what='hour(from_unixtime(ts_line)) as item,hiid,'. join(',',@fields_select);
      my $where="id_dev=$id_dev and dayofmonth(from_unixtime(ts_line))=";
      my $other='order by ts_line';


my $auxtime=$self->time2date($ttl);
my $auxdays=scalar(@$days_range);
$self->log('info',"load_store_graph_data:: $table_source ID_DEV=$id_dev T<$auxtime RANGO DE DIAS=$auxdays");
$self->log('debug',"load_store_graph_data::ID_DEV=$id_dev T<$auxtime (CMD=$libSQL::cmd)");


      my @data=();
      # ----------------------------------------------------------------------
      # Consolido cada uno de los dias
      # ----------------------------------------------------------------------
      foreach my $x (@$days_range) {

         my $time_element=$x->[0];
         my $ts_item=$x->[1];
         my $condition = $where.$time_element;

      # ----------------------------------------------------------------------
      # Obtengo los valores por hora de cada uno de los dias.
      # ----------------------------------------------------------------------
      # SELECT hour(from_unixtime(ts_line)) as item,hiid,v1avg,v1max,v1min FROM __raw__000__1__latency__mon_icmp WHERE id_dev=31 and dayofmonth(from_unixtime(ts_line))=3 order by ts_line;
      # +------+------+------------+----------+----------+
      # | item | hiid | v1avg      | v1max    | v1min    |
      # +------+------+------------+----------+----------+
      # |    1 | ALL  | 0.00168471 | 0.003349 | 0.001334 |
      # |    2 | ALL  |  0.0018925 | 0.007617 | 0.001239 |
      # ......
      # |   22 | ALL  |  0.0025285 | 0.005207 | 0.001268 |
      # |   23 | ALL  | 0.00277058 | 0.007973 | 0.001282 |
      # +------+------+------------+----------+----------+
      # ----------------------------------------------------------------------

         my $rres=sqlSelectAll($dbh,$what,$table_source,$condition,$other);

         $self->error($libSQL::err);
         $self->errorstr($libSQL::errstr);
         $self->lastcmd($libSQL::cmd);

         if ($libSQL::err != 0) {
            $self->log('warning',"load_store_graph_data::[WARN] Error en lectura de $table_source ($libSQL::err) $libSQL::errstr ($libSQL::cmd)");
            next;
         }

#fml
	my $auxh=scalar(@$rres);
   $self->log('debug',"load_store_graph_data::[**DBG**] $table_source ID_DEV=$id_dev RANGO H-D TOT=$auxh (CMD=$libSQL::cmd)");

         # ------------------------------------------------------
         # Bucle de consolidacion
         #my %vdata=();
         #my @vconso=(); # ( {'avg'=>a, 'max'=>b, 'min'=>c}, {} ...)
         my $hiid;
         #my $n=0;
			my %HDATA=();
         foreach my $l (@$rres) {
            my $h=$l->[0];
            $hiid=$l->[1];
				if (!exists $HDATA{$hiid}) { $HDATA{$hiid}=[$l]; }
				else { push @{$HDATA{$hiid}}, $l; }
			}

			foreach my $k (keys %HDATA) {

	         my %vdata=();
   	      my @vconso=(); # ( {'avg'=>a, 'max'=>b, 'min'=>c}, {} ...)
         	my $n=0;

#fml parche para debug
#if ($id_dev !=3) {next; }
#if ($k ne "1") {next; }

	my $auxhiid=scalar(@{$HDATA{$k}});
   $self->log('debug',"load_store_graph_data::[**DBG**] $table_source ID_DEV=$id_dev HIID=$k RANGO H-D=$auxhiid");

				foreach my $l (@{$HDATA{$k}}) {
	            my $h=$l->[0];
   	         $hiid=$l->[1];
      	      my $j=2;

   $self->log('debug',"load_store_graph_data::[**DBG**] $table_source ID_DEV=$id_dev HIID=$k DATA (L) = @$l");

         	   foreach my $i (0..$nitems-1) {
            	   my $avg=$l->[$j];
	               my $max=$l->[$j+1];
   	            my $min=$l->[$j+2];

   $self->log('debug',"load_store_graph_data::[**DBG**] $table_source ID_DEV=$id_dev HIID=$k avg=$avg max=$max min=$min");

      	         if (ref($vconso[$i]) ne "HASH") {
         	        $vconso[$i]->{'avg'}=$avg;
            	     $vconso[$i]->{'max'}=$max;
               	  $vconso[$i]->{'min'}=$min;
               	}
	               else {
   	               $vconso[$i]->{'avg'} += $avg;
      	            if ($max > $vconso[$i]->{'max'}) {$vconso[$i]->{'max'}=$max;}
         	         if ($min < $vconso[$i]->{'min'}) {$vconso[$i]->{'min'}=$min;}
            	   }

               	$j+=3;
	            }
   	         $n+=1;
	         }
   	      foreach my $i (0..$nitems-1) {
      	     $vconso[$i]->{'avg'}/=$n;
         	}
	         my @avg_max_min=();
   	      foreach my $i (0..$nitems-1) {
      	      push @avg_max_min, $vconso[$i]->{'avg'};
         	   push @avg_max_min, $vconso[$i]->{'max'};
            	push @avg_max_min, $vconso[$i]->{'min'};
         	}

$self->log('debug',"load_store_graph_data::[**DBG**] $table_source ID_DEV=$id_dev HIID=$k RESULTS>> $id_dev, $ts_item, $hiid,  @avg_max_min, $id_dev, $ts_item, $hiid,  @avg_max_min");

         	push @data, [$id_dev, $ts_item, $hiid,  @avg_max_min, $id_dev, $ts_item, $hiid,  @avg_max_min];
			}
      }

      # ------------------------------------------------------
      # Se almacenan los datos obtenidos en la tabla de store

      my $sql='INSERT INTO '.$table_dest. ' (' . join(',',@names). ') VALUES ('. join(',',@values).') ON DUPLICATE KEY UPDATE '.join(',',@sets);
      my $rv=sqlCmd_fast($dbh,\@data,$sql);


      $self->log('debug',"load_store_graph_data::[DEBUG] INSERT EN STORE ($libSQL::err) (CMD=$libSQL::cmd)");
      #print "*****>>> SQL=$sql\n";;
      #print Dumper(\@data);

      # ------------------------------------------------------
      # Hay que limpiar las tablas origen y destino (__raw__ y __store__)
      # Estimacion: Cada tabla sporta 1000 metricas diferentes con una profundidad de 800 lineas 
      # cada una, lo que supone una profundidad de:
      # raw: 1000*800 = 800.000 => >1mes
      # store: 1000*800 = 800.000 => >2year

		# ------------------------------------------------------
     sqlDelete($dbh,$table_source,"id_dev=$id_dev and ts_line<$tlimit_raw");

     $self->error($libSQL::err);
     $self->errorstr($libSQL::errstr);
     $self->lastcmd($libSQL::cmd);

     if ($libSQL::err != 0) {
        $self->log('warning',"load_store_graph_data:: **EDB** AL BORRAR en $table_source ($libSQL::err) $libSQL::errstr ($libSQL::cmd)");
     }

		# ------------------------------------------------------
     sqlDelete($dbh,$table_dest,"id_dev=$id_dev and ts_line<$tlimit_store");

     $self->error($libSQL::err);
     $self->errorstr($libSQL::errstr);
     $self->lastcmd($libSQL::cmd);

     if ($libSQL::err != 0) {
        $self->log('warning',"load_store_graph_data:: **EDB** AL BORRAR en $table_dest ($libSQL::err) $libSQL::errstr ($libSQL::cmd)");
     }

   }

}


#----------------------------------------------------------------------------
sub _data_conso {
my ($self,$data)=@_;

   #t1:v1;t2:v2;...;tn:vn
	my ($avg,$aux,$nitems)=(0,0,0);
   my @d1=split(';',$data);
   foreach my $v (@d1) {
      if ($v =~ /(\S+)\:(\S+)/) {
			$aux += $2;
			$nitems += 1;
		}	
   }

	if ($nitems!=0) { $avg=$aux/$nitems; } 	

   return $avg;
}



#----------------------------------------------------------------------------
sub _data_untar {
my ($self,$data,$lapse)=@_;

	#t1:v1;t2:v2;...;tn:vn
	#1295740800:0.075429;1295741100:0.075920;
	my %values=();
	my @d1=split(';',$data);
	my $n=0;
	foreach my $v (@d1) {
		if ($v =~ /(\S+)\:(\S+)/) { $values{$1}=$2;  $n+=1; }
	}

	# Si se especifica un valor de $lapse se rellenan los huecos con 'U'
	if ($lapse  =~ /\d+/) { 
		my @ts=sort keys %values;
		# Si el primer valor es 0. Es un error que puede resultar muy grave, ya que el 
		# vector puede ser monstruoso ....
		if ($ts[0]==0) { 
			shift @ts; 
			delete $values{'0'};
		}
		my $t0=$ts[0];
		for my $i (1..$n-1) {
			while ( ($ts[$i]-$t0) > $lapse )	{
				$t0 += $lapse;
				$values{$t0}='U';
			}
			$t0=$ts[$i];
		}
	}
	return \%values;
}


#----------------------------------------------------------------------------
sub _data_tar {
my ($self,$values)=@_;

	my @data=();
   my ($avg,$max,$min,$n)=(0,'U','U',0);
	foreach my $t (sort { $a <=> $b } keys %$values) {
		push @data, $t.':'.$values->{$t};
      if ($max !~ /\d+/) { $max=$values->{$t}; }
      elsif (($values->{$t}=~/\d+/) && ($values->{$t}>$max)) { $max=$values->{$t}; }
      if ($min !~ /\d+/) { $min=$values->{$t}; }
      elsif (($values->{$t}=~/\d+/) && ($values->{$t}<$min)) { $min=$values->{$t}; }
      if ($values->{$t} =~ /\d+/) { $avg+=$values->{$t}; }
      $n+=1;
	}
   $avg/=$n;
   my $res=join (';', @data);
	return ($res,$avg,$max,$min);
}


#----------------------------------------------------------------------------
# Funcion: oid_info
# Descripcion:
# Actualiza la tabla oid_info si no existe el sysoid que se le pasa como parametro.
# La descripcion es la de GENERICO xxx que se encuentra en oid_enterprises.
# Si la definicion del generico no esta en oid_enterprises, no hace nada.
#----------------------------------------------------------------------------
sub oid_info {
my ($self,$dbh,$oid)=@_;

   if (! defined $dbh) { return undef; }
   if (! defined $oid) { return undef; }

   my $rres=sqlSelectAll($dbh,'device','oid_info',"oid=\'$oid\'");
   if ($rres->[0][0]) {return 1;}

   my $enterprise=undef;
   if (($oid =~ /enterprises(\.\d+)\.*.*/) || ($oid =~ /.1.3.6.1.4.1(\.\d+)\.*.*/) ) {
      $enterprise='.1.3.6.1.4.1'.$1;
   }
   if (! defined $enterprise) { return undef; }

   $rres=sqlSelectAll($dbh,'device','oid_enterprises',"oid=\'$enterprise\'");
   if (! $rres->[0][0]) {return 1;}

   my %table=();
   $table{'device'}=$rres->[0][0];
   $table{'oid'}=$oid;
   $rres=sqlInsert($dbh,'oid_info',\%table,);
   if (! defined $rres) {
      $self->log('warning',"oid_info::[WARN] Error en insert -> oid_info (RV=undef)");
   }

   return $rres;
}


#----------------------------------------------------------------------------
# Funcion: get_mcnm_credentials
#----------------------------------------------------------------------------
# Descripcion: Obtiene de cfg_cnms las credenciales necesarias para conectarse
# a la BBDD cnm.cfg_cnms correspondiente
# db_name ==> /cfg/{db1_name}.conf ==> user,pwd ...
# cid -> {db_server->xxx. db_pwd->yyy, ...}
#-----------------------------------------------------------------------------
sub get_mcnm_credentials {
my ($self,$dbh,$in)=@_;

   if (! defined $dbh) { return undef; }
   if (! defined $in) { return undef; }

	my %data=();
	my $condition;

	if (exists $in->{'cid'}) { 
		$condition="cid=\'".$in->{'cid'}."\'"; 
		if (exists $in->{'host_ip'}) { $condition.=" AND host_ip=\'".$in->{'host_ip'}."\'"; }
	}
	elsif (exists $in->{'hidx'}) { $condition="hidx=\'".$in->{'hidx'}."\'"; }
	elsif (exists $in->{'host_ip'}) { $condition="host_ip=\'".$in->{'host_ip'}."\'"; }

   #my $rres=sqlSelectAll($dbh,'cid,db1_server,db1_pwd,db1_name,db1_user,hidx,host_ip,host_name,id_client','cnm.cfg_cnms',$condition);
   my $rres=sqlSelectAll($dbh,'cid,db1_name,hidx,host_ip,host_name,id_client','cnm.cfg_cnms',$condition);
	foreach my $l (@$rres) {
		my $cid = $l->[0];
		my $db_name = $l->[1];
	   my $fconf='/cfg/'.$l->[1].'.conf';
   	my $rcfg=conf_base($fconf);
		$data{$cid} = {'db_server'=>$rcfg->{'db_server'}->[0], 'db_pwd'=>$rcfg->{'db_pwd'}->[0], 'db_name'=>$db_name, 'db_user'=>$rcfg->{'db_user'}->[0], 'hidx'=>$l->[2], 'host_ip'=>$l->[3], 'host_name'=>$l->[4], 'id_client'=>$l->[5]};
	}

	return \%data;
}



#----------------------------------------------------------------------------
# Funcion: get_mcnm_domain_cids
#----------------------------------------------------------------------------
# Descripcion: Obtiene los integrantes del dominio o dominios de un cid concreto.
# Devuelve una ref a un hash indexado por cid con los datos relevantes de cada 
# uno de ellos.
# cid -> {host_ip->xxx, ...}
#-----------------------------------------------------------------------------
sub get_mcnm_domain_cids {
my ($self,$dbh,$in)=@_;

   if (! defined $dbh) { return undef; }
   if (! defined $in) { return undef; }

   my %data=();
	my $rres=[];
   my $condition;

   if ( (exists $in->{'cid'}) && (exists $in->{'cid_ip'}) ) { 
		$condition="c.hidx=d.hidx and c.cid=\'".$in->{'cid'}."\' and c.host_ip=\'".$in->{'cid_ip'}."\'"; 
		$rres=sqlSelectAll($dbh,'d.id_domain','cnm.cfg_cnms2domains as d, cnm.cfg_cnms as c',$condition);
	}
   elsif (exists $in->{'hidx'}) { 
		$condition="hidx=\'".$in->{'hidx'}."\'"; 
		$rres=sqlSelectAll($dbh,'id_domain','cnm.cfg_cnms2domains',$condition);
	}
	else { return {}; }

#SELECT d.id_domain FROM cnm.cfg_cnms2domains as d, cnm.cfg_cnms as c WHERE c.hidx=d.hidx and c.cid='default';
#SELECT a.host_ip, a.host_name, a.host_descr, a.hidx,a.cid FROM cnm.cfg_cnms a, cnm.cfg_cnms2domains b WHERE a.hidx=b.hidx AND b.id_domain=1  ORDER BY a.host_name;

	# Para cada dominio
   foreach my $l (@$rres) {
      my $id_domain=$l->[0];
		$condition="a.hidx=b.hidx AND b.id_domain=$id_domain";
		my $rres1=sqlSelectAll($dbh,'a.cid,a.host_ip,a.hidx,a.mode','cnm.cfg_cnms a, cnm.cfg_cnms2domains b',$condition);
		foreach my $x (@$rres1) {
			# Salto el cid propio
			if ( ($x->[0] eq $in->{'cid'}) && ($x->[1] eq $in->{'cid_ip'}) ) { next;}
			my $index=$x->[0].'-'.$x->[1];
	      $data{$index} = { 'cid'=>$x->[0], 'host_ip'=>$x->[1], 'hidx'=>$x->[2], 'mode'=>$x->[3] };
		}
   }

   return \%data;
}

#----------------------------------------------------------------------------
# Funcion: get_mcnm_status
#----------------------------------------------------------------------------
# Descripcion: Obtiene el estado almacenado de todos los CNMs remotos.
# El parametro $in especifica cid y cid_ip locales para no incluirlos en la respuesta.
# Devuelve una ref a un hash indexado por cid-cid_ip con el valor del estado.
#-----------------------------------------------------------------------------
sub get_mcnm_status {
my ($self,$dbh,$in)=@_;

   my %data=();
   if (! defined $dbh) { return \%data; }

   my $rres=sqlSelectAll($dbh,'cid,cid_ip,status,counter','cnm_status','');

   foreach my $x (@$rres) {
      # Salto el cid propio
      if ( ($x->[0] eq $in->{'cid'}) && ($x->[1] eq $in->{'cid_ip'}) ) { next;}
      my $index=$x->[0].'-'.$x->[1];
      $data{$index} = { 'status'=>$x->[2], 'counter'=>$x->[3] };
   }

   return \%data;
}

#----------------------------------------------------------------------------
# Funcion: store_crawler_work
#----------------------------------------------------------------------------
# Descripcion: Almacena en las tablas globales work_xxxx (bbdd cnm) las tareas
# que van a realizar los diferentes crawlers.
# BBDD onm -> BBDD cnm
#-----------------------------------------------------------------------------
sub store_crawler_work {
my ($self,$dbh,$id_dev,$tnow,$cid)=@_;
my $rres=undef;
my @data=();
my ($what,$from,$where,$sql,$rv);

	#my $cid='default';
	my $nitems=1;
	if (! $tnow) { $tnow=time; }
	$self->log('info',"store_crawler_work:: >>>> id_dev=$id_dev cid=$cid tnow=$tnow");

   # ---------------------------------------------------------
	# Se obtiene la IP del id_dev para garantizar que se borran posibles metricas obsoletas.
	# Si se cambia el nombre de un dispositivo, se genera un nuevo id_dev y al regenerar/limpiar metricas antiguas
	# se usa este nuevo id_dev. Por eso en situaciones raras como estas es necesario limpiar posibles metricas asocidas
	# al id_dev antiguo y eso lo detectamos utilizando la ip.
	$rres=sqlSelectAll($dbh,'ip','devices',"id_dev=$id_dev");
	my $dev_ip=$rres->[0][0];

	# Se obtienen las metricas de id_dev
	# ---------------------------------------------------------
	# SNMP
	# ---------------------------------------------------------

   # ---------------------------------------------------------
   # Lo primero se obtienen las credentials de snmpv3 en %v3prof
   $rres=sqlSelectAll($dbh,'id_profile,sec_name,sec_level,auth_proto,auth_pass,priv_proto,priv_pass,profile_name','profiles_snmpv3','');
   my %v3prof=();
   foreach my $m (@$rres) {
      my $id_profile=$m->[0];
		#id_profile,sec_name,sec_level,auth_proto,auth_pass,priv_proto,priv_pass,profile_name
      $v3prof{$id_profile}=join(';', @$m);
   }
	# ---------------------------------------------------------

   $what='d.name,d.domain,d.ip,d.version,d.community as credentials,m.id_dev,m.id_dest,m.id_metric,m.name as mname,m.type,m.subtype,m.label,m.host,m.top_value,m.file,m.mtype,m.mode,m.module,m.watch,m.severity,m.host_idx,m.iid,m.subtable,m.lapse,c.oid,t.get_iid,t.cfg,t.esp,d.status,t.descr as cause,t.params';
   $from='devices d,metrics m, metric2snmp c, cfg_monitor_snmp t';
   $where="d.status in (0,2) and m.status=0 and m.type='snmp' and d.id_dev=$id_dev and d.id_dev=m.id_dev and m.id_metric=c.id_metric and m.subtype=t.subtype ";

   $rres=sqlSelectAll($dbh,$what,$from,$where,'');
   $self->error($libSQL::err);
   $self->errorstr($libSQL::errstr);
   $self->lastcmd($libSQL::cmd);

   if ($libSQL::err) {
      #$self->log('warning',"store_crawler_work::[DBERROR] (EDB=$libSQL::err) $libSQL::errstr ($libSQL::cmd)");
		$self->manage_db_error($dbh,"store_crawler_work");
      return undef;
   }

	@data=();
   foreach my $l (@$rres) {

		#snmpv3
		if ( ($l->[3]==3) && (exists $v3prof{$l->[4]}) ) { $l->[4]=$v3prof{$l->[4]}; }

		my @xitems=split(/\|/,$l->[24]);
		$nitems = scalar(@xitems);
		push @$l,$nitems,$cid,$tnow;
		push @data, [@$l,@$l];
	}

   $sql="INSERT INTO cnm.work_snmp (name,domain,ip,version,credentials,id_dev,id_dest,id_metric,mname,type,subtype,label,host,top_value,file,mtype,mode,module,watch,severity,host_idx,iid,subtable,lapse,oid,get_iid,cfg,esp,status,cause,params,nitems,cid,date) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?) ON DUPLICATE KEY UPDATE  name=?, domain=?, ip=?, version=?, credentials=?, id_dev=?, id_dest=?, id_metric=?, mname=?, type=?, subtype=?, label=?, host=?, top_value=?, file=?, mtype=?, mode=?, module=?, watch=?, severity=?, host_idx=?, iid=?, subtable=?, lapse=?, oid=?, get_iid=?, cfg=?, esp=?, status=?, cause=?, params=?, nitems=?, cid=?, date=?";
   $rv=sqlCmd_fast($dbh,\@data,$sql);

	# ---------------------------------------------------------
	# Se obtiene la info sobre los monitores definidos sobre estas metricas
	# select m.id_metric,a.cause,a.severity,a.expr,a.params from metrics m, alert_type a WHERE  m.watch=a.monitor and m.type='snmp';
   $rres=sqlSelectAll($dbh,"a.cause,a.severity,a.expr,m.id_metric,\'$cid\' as cid",'metrics m, alert_type a',"m.id_dev=$id_dev and m.watch=a.monitor and m.type='snmp'",'');
   $self->error($libSQL::err);
   $self->errorstr($libSQL::errstr);
   $self->lastcmd($libSQL::cmd);

   if ($libSQL::err) {
      #$self->log('warning',"store_crawler_work::[DBERROR] (EDB=$libSQL::err) $libSQL::errstr ($libSQL::cmd)");
		$self->manage_db_error($dbh,"store_crawler_work");
      return undef;
   }

	$sql="UPDATE cnm.work_snmp SET cause=?, severity=?, expr=? WHERE id_dev=$id_dev and id_metric=? and cid=?";
	$rv=sqlCmd_fast($dbh,$rres,$sql);


	# ---------------------------------------------------------
	# Se eliminan las metricas obsoletas (baja, mantenimiento ...)
	sqlDelete($dbh,'cnm.work_snmp',"(id_dev=$id_dev or ip='$dev_ip') and date<$tnow");


	# ---------------------------------------------------------
	#latency
	# ---------------------------------------------------------
   $what='d.name,d.domain,d.ip,d.id_dev,m.id_dest,m.id_metric,m.name as mname,m.type,m.subtype,m.label,m.host,m.top_value,m.file,m.mtype,m.mode,m.module,m.watch,m.severity,m.host_idx,m.iid,m.subtable,m.lapse,c.monitor,c.monitor_data,d.status,t.description as cause';
   $from='devices d,metrics m, metric2latency c, cfg_monitor t';
   $where="d.status in (0,2) and m.status=0 and m.type='latency' and d.id_dev=$id_dev and d.id_dev=m.id_dev and m.id_metric=c.id_metric and m.subtype=t.monitor ";

   $rres=sqlSelectAll($dbh,$what,$from,$where,'');
   $self->error($libSQL::err);
   $self->errorstr($libSQL::errstr);
   $self->lastcmd($libSQL::cmd);

   if ($libSQL::err) {
      #$self->log('warning',"store_crawler_work::[DBERROR] (EDB=$libSQL::err) $libSQL::errstr ($libSQL::cmd)");
		$self->manage_db_error($dbh,"store_crawler_work");
      return undef;
   }

   @data=();
   foreach my $l (@$rres) {
		push @$l,$cid,$tnow;
      push @data, [@$l,@$l];
   }


   $sql="INSERT INTO cnm.work_latency (name,domain,ip,id_dev,id_dest,id_metric,mname,type,subtype,label,host,top_value,file,mtype,mode,module,watch,severity,host_idx,iid,subtable,lapse,monitor,monitor_data,status,cause,cid,date) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?) ON DUPLICATE KEY UPDATE  name=?, domain=?, ip=?, id_dev=?, id_dest=?, id_metric=?, mname=?, type=?, subtype=?, label=?, host=?, top_value=?, file=?, mtype=?, mode=?, module=?, watch=?, severity=?, host_idx=?, iid=?, subtable=?, lapse=?, monitor=?, monitor_data=?, status=?, cause=?, cid=?, date=?";
   $rv=sqlCmd_fast($dbh,\@data,$sql);

   # Se obtiene la info sobre los monitores definidos sobre estas metricas
   # select m.id_metric,a.cause,a.severity,a.expr,a.params from metrics m, alert_type a WHERE  m.watch=a.monitor and m.type='latency';
   $rres=sqlSelectAll($dbh,"a.cause,a.severity,a.expr,m.id_metric,\'$cid\' as cid",'metrics m, alert_type a',"m.id_dev=$id_dev and m.watch=a.monitor and m.type='latency'",'');
   $self->error($libSQL::err);
   $self->errorstr($libSQL::errstr);
   $self->lastcmd($libSQL::cmd);

   if ($libSQL::err) {
      #$self->log('warning',"store_crawler_work::[DBERROR] (EDB=$libSQL::err) $libSQL::errstr ($libSQL::cmd)");
		$self->manage_db_error($dbh,"store_crawler_work");
      return undef;
   }

   $sql="UPDATE cnm.work_latency SET cause=?, severity=?, expr=? WHERE id_dev=$id_dev and id_metric=? and cid=?";
   $rv=sqlCmd_fast($dbh,$rres,$sql);

   # ---------------------------------------------------------
   # Se eliminan las metricas obsoletas (baja, mantenimiento ...)
   sqlDelete($dbh,'cnm.work_latency',"(id_dev=$id_dev or ip='$dev_ip') and date<$tnow");

	# ---------------------------------------------------------
	# xagent
	# ---------------------------------------------------------
   $what='d.name,d.domain,d.ip,d.xagent_version as version,d.id_dev,m.id_dest,m.id_metric,m.name as mname,m.type,m.subtype,m.label,m.host,m.top_value,m.file,m.mtype,m.mode,m.module,m.watch,m.severity,m.host_idx,m.iid,m.subtable,m.lapse,c.script,c.params,c.nparams,c.class,c.items,c.cfg,c.custom,c.get_iid,c.id_proxy,d.status,c.description as cause,c.tag,c.esp,s.proxy_type,s.proxy_user,s.timeout';
   $from='devices d,metrics m, cfg_monitor_agent c, cfg_monitor_agent_script s';
   $where="c.script=s.script and d.status in (0,2) and m.status=0 and m.type='xagent' and d.id_dev=$id_dev and d.id_dev=m.id_dev and c.subtype=m.subtype ";
   #$where="d.status=0 and m.status=0 and m.type='xagent' and d.id_dev=m.id_dev and c.subtype=m.subtype and c.id_proxy=0 ";

   $rres=sqlSelectAll($dbh,$what,$from,$where,'');
   $self->error($libSQL::err);
   $self->errorstr($libSQL::errstr);
   $self->lastcmd($libSQL::cmd);

   if ($libSQL::err) {
      #$self->log('warning',"store_crawler_work::[DBERROR] (EDB=$libSQL::err) $libSQL::errstr ($libSQL::cmd)");
		$self->manage_db_error($dbh,"store_crawler_work");
      return undef;
   }

   @data=();
   foreach my $l (@$rres) {
      my @xitems=split(/\|/,$l->[27]);
      $nitems = scalar(@xitems);
		push @$l,$nitems,$cid,$tnow;
      push @data, [@$l,@$l];
   }

   $sql="INSERT INTO cnm.work_xagent (name,domain,ip,version,id_dev,id_dest,id_metric,mname,type,subtype,label,host,top_value,file,mtype,mode,module,watch,severity,host_idx,iid,subtable,lapse,script,params,nparams,class,items,cfg,custom,get_iid,id_proxy,status,cause,tag,esp,proxy_type,proxy_user,timeout,nitems,cid,date) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?) ON DUPLICATE KEY UPDATE  name=?, domain=?, ip=?, version=?, id_dev=?, id_dest=?, id_metric=?, mname=?, type=?, subtype=?, label=?, host=?, top_value=?, file=?, mtype=?, mode=?, module=?, watch=?, severity=?, host_idx=?, iid=?, subtable=?, lapse=?, script=?, params=?, nparams=?, class=?, items=?, cfg=?, custom=?, get_iid=?, id_proxy=?, status=?,  cause=?, tag=?, esp=?, proxy_type=?, proxy_user=?, timeout=?, nitems=?, cid=?, date=?";
   $rv=sqlCmd_fast($dbh,\@data,$sql);


   # Se obtiene la info sobre los monitores definidos sobre estas metricas
   # select m.id_metric,a.cause,a.severity,a.expr,a.params from metrics m, alert_type a WHERE  m.watch=a.monitor and m.type='xagent';
   $rres=sqlSelectAll($dbh,"a.cause,a.severity,a.expr,m.id_metric,\'$cid\' as cid",'metrics m, alert_type a',"m.id_dev=$id_dev and m.watch=a.monitor and m.type='xagent'",'');
   $self->error($libSQL::err);
   $self->errorstr($libSQL::errstr);
   $self->lastcmd($libSQL::cmd);

   if ($libSQL::err) {
      #$self->log('warning',"store_crawler_work::[DBERROR] (EDB=$libSQL::err) $libSQL::errstr ($libSQL::cmd)");
		$self->manage_db_error($dbh,"store_crawler_work");
      return undef;
   }

   $sql="UPDATE cnm.work_xagent SET cause=?, severity=?, expr=? WHERE id_dev=$id_dev and id_metric=? and cid=?";
   $rv=sqlCmd_fast($dbh,$rres,$sql);

   # ---------------------------------------------------------
   # Se eliminan las metricas obsoletas (baja, mantenimiento ...)
   sqlDelete($dbh,'cnm.work_xagent',"(id_dev=$id_dev or ip='$dev_ip') and date<$tnow");


	#-------------------------------------------------------------------
   #Se generan los ficheros idx correspondientes para los crawlers
	#-------------------------------------------------------------------
   $self->consolidate_work_tables($dbh);

}



#----------------------------------------------------------------------------
# Funcion: consolidate_work_tables
#----------------------------------------------------------------------------
# Descripcion: Consolida los valores de crawler_idx en las tablas globales 
# work_xxxx (bbdd cnm) las tareas que van a realizar los diferentes crawlers.
#-----------------------------------------------------------------------------
sub consolidate_work_tables_old {
my ($self,$dbh)=@_;
my $rres=undef;
my @data=();
my ($what,$from,$where,$sql,$rv);

	my %work_tables = (
		'work_snmp-60' => {'block_size'=>60, 'range'=>1000},
		'work_latency-60' => {'block_size'=>60, 'range'=>2000},
		'work_xagent-60' => {'block_size'=>60, 'range'=>3000},
		'work_snmp-300' => {'block_size'=>450, 'range'=>4000},
		'work_latency-300' => {'block_size'=>400, 'range'=>5000},
		'work_xagent-300' => {'block_size'=>400, 'range'=>6000},
		'work_snmp-3600' => {'block_size'=>4500, 'range'=>7000},
		'work_latency-3600' => {'block_size'=>4500, 'range'=>8000},
		'work_xagent-3600' => {'block_size'=>4500, 'range'=>9000},
	);

	my $rcfg=$self->cfg();
	if (exists $rcfg->{'max_60_snmp'}->[0]) { $work_tables{'work_snmp-60'}->{'block_size'}=$rcfg->{'max_60_snmp'}->[0]; }
	if (exists $rcfg->{'max_300_snmp'}->[0]) { $work_tables{'work_snmp-300'}->{'block_size'}=$rcfg->{'max_300_snmp'}->[0]; }
	if (exists $rcfg->{'max_3600_snmp'}->[0]) { $work_tables{'work_snmp-3600'}->{'block_size'}=$rcfg->{'max_3600_snmp'}->[0]; }

	if (exists $rcfg->{'max_60_latency'}->[0]) { $work_tables{'work_latency-60'}->{'block_size'}=$rcfg->{'max_60_latency'}->[0]; }
	if (exists $rcfg->{'max_300_latency'}->[0]) { $work_tables{'work_latency-300'}->{'block_size'}=$rcfg->{'max_300_latency'}->[0]; }
	if (exists $rcfg->{'max_3600_latency'}->[0]) { $work_tables{'work_latency-3600'}->{'block_size'}=$rcfg->{'max_3600_latency'}->[0]; }

	if (exists $rcfg->{'max_60_xagent'}->[0]) { $work_tables{'work_xagent-60'}->{'block_size'}=$rcfg->{'max_60_xagent'}->[0]; }
	if (exists $rcfg->{'max_300_xagent'}->[0]) { $work_tables{'work_xagent-300'}->{'block_size'}=$rcfg->{'max_300_xagent'}->[0]; }
	if (exists $rcfg->{'max_3600_xagent'}->[0]) { $work_tables{'work_xagent-3600'}->{'block_size'}=$rcfg->{'max_3600_xagent'}->[0]; }


	foreach my $table_lapse (sort keys %work_tables) {

		my ($table,$lapse)=split(/\-/,$table_lapse);
		my $start=0;
		my $i=0;
		my $block_size=$work_tables{$table_lapse}->{'block_size'};

	   $rres=sqlSelectAll($dbh,'count(*)',"cnm.$table","lapse=$lapse",'');
		my $total_metrics=$rres->[0][0];

      $self->log('info',"consolidate_work_tables:: TABLE=$table LAPSE=$lapse BLOCK_SIZE=$block_size TOTAL=$total_metrics");
		

		#####################
		# Para SNMP contemplo el caso de equipos con muchas metricas
		# select id_dev, count(*) as c from cnm.work_snmp group by id_dev order by c desc
		# si count > block_size Se asignan todas a un unico crawler
		my @big=();
		if ($table_lapse eq 'work_snmp-300') {

	      my $rresx=sqlSelectAll($dbh,'id_dev, count(*) as cuantos',"cnm.$table",'','group by id_dev order by cuantos desc');
			foreach my $l (@$rresx) {
				my $iddev=$l->[0];
         	my $cuantos=$l->[1];
				if ($cuantos < $block_size) { last; }
	
				push @big, $iddev;	
	         my $crawler_idx=$work_tables{$table_lapse}->{'range'} + $i;
   	      # Todas las metricas snmp-300 del dispositivo iddev se asignan a $crawler_idx
      	   $rres=sqlSelectAll($dbh,'id_work',"cnm.$table","lapse=$lapse AND id_dev=$iddev",'');
         	$self->error($libSQL::err);
         	$self->errorstr($libSQL::errstr);
         	$self->lastcmd($libSQL::cmd);

	         if ($libSQL::err) {
      	      $self->manage_db_error($dbh,"consolidate_work_tables");
         	   return undef;
         	}

	         my @data=();
   	      foreach my $l (@$rres) {
      	      push @data,$l->[0];
         	}

	         # Actualiza dicho bloque con los valores correctos de crawler_idx
   	      my $where = 'id_work IN (' . join(',', @data) . ')';
      	   $rv=sqlUpdate($dbh,"cnm.$table",{'crawler_idx'=>$crawler_idx},$where);
         	$self->log('debug',"consolidate_work_tables:: crawler_idx=$crawler_idx ==> iddev=$iddev block_size=$block_size");

	         $self->work_table_to_file($dbh,$table,$crawler_idx);

   	      # Prepara siguiente iteracion
      	   # $start+=$cuantos;
      	   $total_metrics-=$cuantos;
         	$i+=1;


			}

		}
		#####################

		my $big_data=join(',', @big);
		if (scalar(@big)==0) { $big_data=0; }

		while ($start<$total_metrics) {

			my $crawler_idx=$work_tables{$table_lapse}->{'range'} + $i;
			# Obtiene las metricas del bloque seleccionado para el tipo x
			# Excluyendo al caso de dispositivos con muchas metricas snmp-300 ($big_data)
		   $rres=sqlSelectAll($dbh,'id_work',"cnm.$table","lapse=$lapse AND id_dev NOT IN ($big_data)","order by id_dev limit $start,$block_size");
   		$self->error($libSQL::err);
	   	$self->errorstr($libSQL::errstr);
   		$self->lastcmd($libSQL::cmd);

		   if ($libSQL::err) {
				$self->manage_db_error($dbh,"consolidate_work_tables");
      		return undef;
   		}

		   my @data=();
   		foreach my $l (@$rres) {
				push @data,$l->[0];
   		}

			# Actualiza dicho bloque con los valores correctos de crawler_idx
   		my $where = 'id_work IN (' . join(',', @data) . ')';
   		$rv=sqlUpdate($dbh,"cnm.$table",{'crawler_idx'=>$crawler_idx},$where);

	      $self->log('debug',"consolidate_work_tables:: crawler_idx=$crawler_idx start=$start block_size=$block_size");

			$self->work_table_to_file($dbh,$table,$crawler_idx);

			# Prepara siguiente iteracion
			$start+=$block_size;
			$i+=1;
		}
	}
}

#file=0000000018/disp_icmp-H0.rrd _o&o_ 
#hash=fe84e67ce4372a2dc547636f596966ef _o&o_ 
#host_ip=10.2.254.243 _o&o_ 
#host_name=diodo-tx _o&o_ 
#iddev=18 _o&o_ 
#idmetric=1066 _o&o_ 
#iid=ALL _o&o_ 
#label=DISPONIBILIDAD ICMP (ping) (diodo-tx.s30labs.com) _o&o_ 
#lapse=60 _o&o_ 
#max=  _o&o_ 
#mode=GAUGE _o&o_ 
#module=mod_monitor_ext:ext_dispo_base _o&o_ 
#monitor=disp_icmp _o&o_ 
#mtype=H0_SOLID _o&o_ 
#name=disp_icmp _o&o_ 
#severity=2 _o&o_ 
#subtype=disp_icmp _o&o_ 
#type=latency _o&o_ 
#watch=0
#
#

#cfg=2 _o&o_ 
#community=cnmrocom _o&o_ 
#file=0000000003/traffic_mibii_if-1-STD.rrd _o&o_ 
#get_iid=1 _o&o_ 
#hash=e00e5b40d760cab50420867ab7619f6c _o&o_ 
#host_ip=10.2.254.221 _o&o_ 
#host_name=cnm-devel1 _o&o_ 
#iddev=3 _o&o_ 
#idmetric=665 _o&o_ 
#iid=1 _o&o_ 
#label=Trafico lo (cnm-devel2.s30labs.com) _o&o_ 
#lapse=300 _o&o_ 
#max=  _o&o_ 
#mode=COUNTER _o&o_ 
#module=mod_snmp_get _o&o_ 
#mtype=STD_TRAFFIC _o&o_ 
#name=traffic_mibii_if-1 _o&o_ 
#oid=.1.3.6.1.2.1.2.2.1.10.1|.1.3.6.1.2.1.2.2.1.16.1 _o&o_ 
#severity=2 _o&o_ 
#subtype=traffic_mibii_if _o&o_ 
#type=snmp _o&o_ 
#version=2 _o&o_ 
#watch=0
#
#
#
#cfg=1 _o&o_ class=proxy-linux _o&o_ custom=0 _o&o_ file=0000000013/xagt_004000-STD.rrd _o&o_ get_iid=0 _o&o_ hash=385008e4e77ef7d975285b5cd606925f _o&o_ host_ip=10.2.254.220 _o&o_ host_name=server1 _o&o_ id_proxy=3 _o&o_ iddev=13 _o&o_ idmetric=2427 _o&o_ iid=ALL _o&o_ items=Time _o&o_ label=CADUCIDAD DE UN CERTIFICADO SSL (server1.s30labs.com) _o&o_ lapse=300 _o&o_ max=  _o&o_ mode=GAUGE _o&o_ module=mod_xagent_get _o&o_ mtype=STD_AREA _o&o_ name=xagt_004000 _o&o_ nparams=1 _o&o_ params=[;Puerto;443] _o&o_ script=linux_metric_certificate_expiration_time.pl _o&o_ severity=2 _o&o_ subtype=xagt_004000 _o&o_ type=xagent _o&o_ watch=0
#
#
#cfg=3 _o&o_ community=public _o&o_ file=0000000019/esp_arp_mibii_cnt-STD.rrd _o&o_ get_iid=1 _o&o_ hash=6a279ac5f0d0c7b120639f06759748e6 _o&o_ host_ip=10.2.254.69 _o&o_ host_name=aspire _o&o_ iddev=19 _o&o_ idmetric=1099 _o&o_ iid=ALL _o&o_ label=VECINOS EN LAN - ARP (aspire.s30labs.com) _o&o_ lapse=3600 _o&o_ max=  _o&o_ mode=GAUGE _o&o_ module=mod_snmp_walk:match(.*)(txt=1;v1=2) _o&o_ mtype=STD_BASE _o&o_ name=esp_arp_mibii_cnt _o&o_ oid=ipNetToMediaNetAddress_ipNetToMediaPhysAddress _o&o_ severity=2 _o&o_ subtype=esp_arp_mibii_cnt _o&o_ type=snmp _o&o_ version=2 _o&o_ watch=0



#-----------------------------------------------------------------------------
sub consolidate_work_tables {
my ($self,$dbh)=@_;
my $rres=undef;
my @data=();
my ($what,$from,$where,$sql,$rv);

   my %work_tables = (
      'work_snmp-60' => {'block_size'=>60, 'range'=>1000},
      'work_latency-60' => {'block_size'=>60, 'range'=>2000},
      'work_xagent-60' => {'block_size'=>60, 'range'=>3000},
      'work_snmp-300' => {'block_size'=>450, 'range'=>4000},
      'work_latency-300' => {'block_size'=>400, 'range'=>5000},
      'work_xagent-300' => {'block_size'=>400, 'range'=>6000},
      'work_snmp-3600' => {'block_size'=>4500, 'range'=>7000},
      'work_latency-3600' => {'block_size'=>4500, 'range'=>8000},
      'work_xagent-3600' => {'block_size'=>4500, 'range'=>9000},
   );

	#-------------------------------------
   my $rcfg=$self->cfg();
	my ($factor_iid,$factor_snmp,$factor_latency,$factor_xagent)=(0.1, 2.6, 0.8, 2);
   if ((exists $rcfg->{'factor_iid'}->[0]) && ($rcfg->{'factor_iid'}->[0]=~/^[\d+|\.]+$/)) { $factor_iid=$rcfg->{'factor_iid'}->[0]; }
   if ((exists $rcfg->{'factor_snmp'}->[0]) && ($rcfg->{'factor_snmp'}->[0]=~/^[\d+|\.]+$/)) { $factor_snmp=$rcfg->{'factor_snmp'}->[0]; }
   if ((exists $rcfg->{'factor_latency'}->[0]) && ($rcfg->{'factor_latency'}->[0]=~/^[\d+|\.]+$/)) { $factor_latency=$rcfg->{'factor_latency'}->[0]; }
   if ((exists $rcfg->{'factor_xagent'}->[0]) && ($rcfg->{'factor_xagent'}->[0]=~/^[\d+|\.]+$/)) { $factor_xagent=$rcfg->{'factor_xagent'}->[0]; }
	$self->log('info',"consolidate_work_tables:: factor_iid=$factor_iid factor_snmp=$factor_snmp factor_latency=$factor_latency factor_xagent=$factor_xagent");
	#-------------------------------------

open (W,'>/tmp/workset.log');
	
   foreach my $table_lapse (sort keys %work_tables) {
		
      my ($table,$lapse)=split(/\-/,$table_lapse);
      my $start=0;
      my $i=0;
      my $crawler_idx=$work_tables{$table_lapse}->{'range'} + $i;

      $rres=sqlSelectAll($dbh,'count(*)',"cnm.$table","lapse=$lapse",'');
      my $total_metrics=$rres->[0][0];

      $self->log('info',"consolidate_work_tables:: $table_lapse TOTAL=$total_metrics");

      my $tavailable=$lapse;
      my @update_ids=();

      #----------------------------------------------------------------------------
		my $iddev_pre=0;
		my %m2subtype=();
      my $rresx=sqlSelectAll($dbh,'id_work,id_dev,subtype,cfg,nitems',"cnm.$table","lapse=$lapse",'order by id_dev,cfg');
      foreach my $l (@$rresx) {
         my ($idwork,$iddev,$subtype,$cfg,$nitems)=($l->[0],$l->[1],$l->[2],$l->[3],$l->[4]);

         push @update_ids,$idwork;
			if (! exists $m2subtype{$subtype}) { $m2subtype{$subtype}=1; }	
			else { $m2subtype{$subtype}+=1; }

			# Si hay cambio de dispositivo se calcula el tavailable
			if (($iddev_pre!=0) && ($iddev != $iddev_pre)) {
		
				my $dev_lapse=0;
				foreach my $s (keys %m2subtype) {
					if ($m2subtype{$s}>1) { $dev_lapse += int (($factor_iid*$m2subtype{$s})+2); }
					else {
						if ($table eq 'work_snmp') {  $dev_lapse += ($nitems*$factor_snmp); }
						elsif ($table eq 'work_latency') { $dev_lapse += $factor_latency;  }
						elsif ($table eq 'work_xagent') {  $dev_lapse += $factor_xagent; }
         			else { $tavailable += 1; }
					}
print W "$table_lapse\t$crawler_idx\t[$iddev-$s] nitems=$nitems m2s=$m2subtype{$s} dev_lapse=$dev_lapse\n";

				}
				$tavailable -= $dev_lapse;
				%m2subtype=();
print W "$table_lapse\t$crawler_idx\t[$iddev] ==> tavailable=$tavailable\n";
			}

			$iddev_pre=$iddev;

#$self->log('debug',"consolidate_work_tables:: $table_lapse $crawler_idx [$idwork]  tavailable=$tavailable");

         if ($tavailable <= 0) {
            my $total_metrics = scalar(@update_ids);
            $self->log('debug',"consolidate_work_tables:: **WRITE** $table_lapse $crawler_idx TOTAL=$total_metrics");

            # Actualiza dicho bloque con los valores correctos de crawler_idx
            my $where = 'id_work IN (' . join(',', @update_ids) . ')';
            $rv=sqlUpdate($dbh,"cnm.$table",{'crawler_idx'=>$crawler_idx},$where);
            $self->work_table_to_file($dbh,$table,$crawler_idx);

print W "****WRITE****$table_lapse\t$crawler_idx\t$total_metrics\n";

				$tavailable = $lapse;
            $i+=1;
				$crawler_idx=$work_tables{$table_lapse}->{'range'} + $i;
            @update_ids=();
         }
      }

      if (scalar(@update_ids)>0) {
         my $total_metrics = scalar(@update_ids);
         $self->log('debug',"consolidate_work_tables:: **WRITE** $table_lapse $crawler_idx TOTAL=$total_metrics");

         # Actualiza dicho bloque con los valores correctos de crawler_idx
         my $where = 'id_work IN (' . join(',', @update_ids) . ')';
         $rv=sqlUpdate($dbh,"cnm.$table",{'crawler_idx'=>$crawler_idx},$where);
         $self->work_table_to_file($dbh,$table,$crawler_idx);

print W "****WRITE(resto)****$table_lapse\t$crawler_idx\t$total_metrics\n";

      }
		$self->clean_idx_files($crawler_idx);
   }
close W;

}




#----------------------------------------------------------------------------
# Funcion: work_table_to_file
#----------------------------------------------------------------------------
# Descripcion: Genera el fichero de trabajo para el crawler_idx correspondiente
# a partir de las tablas work_xxxx (bbdd cnm).
#-----------------------------------------------------------------------------
sub work_table_to_file {
my ($self,$dbh,$table,$crawler_idx)=@_;
my $rres=undef;
my @data=();
my ($what,$from,$where,$sql,$rv);

	my $idx = sprintf("%05d", $crawler_idx);
	if (! -d "$Crawler::MDATA_PATH/input") { mkdir "$Crawler::MDATA_PATH/input"; }
	if (! -d "$Crawler::MDATA_PATH/input/idx") { mkdir "$Crawler::MDATA_PATH/input/idx"; }

$self->log('debug',"work_table_to_file:: crawler_idx=$crawler_idx idx=$idx");

	#---------------------------------------------------------
	#snmp 
	#---------------------------------------------------------
	if ($table eq 'work_snmp') {

      $rres=sqlSelectAll($dbh,'ip,name,domain,id_dev,id_metric,iid,cause,mode,module,watch as monitor,mtype,mname,severity,type,subtype,watch,version,credentials,get_iid,oid,cfg,file,esp,subtable,status,top_value,params,cid',"cnm.$table","crawler_idx=$crawler_idx",'');

      $self->error($libSQL::err);
      $self->errorstr($libSQL::errstr);
      $self->lastcmd($libSQL::cmd);

      if ($libSQL::err) {
         #$self->log('warning',"work_table_to_file::[DBERROR] (EDB=$libSQL::err) $libSQL::errstr ($libSQL::cmd)");
			$self->manage_db_error($dbh,"work_table_to_file");
         return undef;
      }

      my $fdata1="$Crawler::MDATA_PATH/input/idx/\.$idx\.info";
      my $fdata2="$Crawler::MDATA_PATH/input/idx/$idx\.info";
$self->log('debug',"work_table_to_file:: FILE=$fdata1");
      open (F,">$fdata1");
      foreach my $l (@$rres) {
			my $host_name=$l->[1].'.'.$l->[2];
			my $subtable=sprintf("%03d", $l->[23]);
			my %h=('host_ip'=>$l->[0], 'host_name'=>$host_name, 'hname'=>$l->[1], 'hdomain'=>$l->[2], 'iddev'=>$l->[3], 'idmetric'=>$l->[4], 'iid'=>$l->[5], 'cause'=>$l->[6], 'mode'=>$l->[7], 'module'=>$l->[8], 'watch'=>$l->[9], 'mtype'=>$l->[10], 'name'=>$l->[11], 'severity'=>$l->[12], 'type'=>$l->[13], 'subtype'=>$l->[14], 'watch'=>$l->[15], 'version'=>$l->[16], 'get_iid'=>$l->[18], 'oid'=>$l->[19], 'cfg'=>$l->[20], 'file'=>$l->[21], 'esp'=>$l->[22], 'subtable'=>$subtable, 'status'=>$l->[24], 'top_value'=>$l->[25], 'params'=>$l->[26], 'cid'=>$l->[27]);
			if ($l->[16] eq '3') { $h{'credentials'}=$l->[17]; }
			else {$h{'community'}=$l->[17]; }
			
			print F encode_json(\%h). "\n";
      }
      close F;
		my $rx=copy($fdata1,$fdata2);
		if (! $rx) {
			$self->log('warning',"work_table_to_file:: **ERROR AL MOVER FICHERO** ($!) $fdata1->$fdata2");
		}
		unlink $fdata1;
	}

	#---------------------------------------------------------
	#latency
	#---------------------------------------------------------
	elsif ($table eq 'work_latency') {
	
      $rres=sqlSelectAll($dbh,'ip,name,domain,id_dev,id_metric,iid,cause,mode,module,subtype as monitor,mtype,mname,severity,type,subtype,watch,monitor_data,file,subtable,status,top_value,cid',"cnm.$table","crawler_idx=$crawler_idx",'');

      $self->error($libSQL::err);
      $self->errorstr($libSQL::errstr);
      $self->lastcmd($libSQL::cmd);

      if ($libSQL::err) {
         #$self->log('warning',"work_table_to_file::[DBERROR] (EDB=$libSQL::err) $libSQL::errstr ($libSQL::cmd)");
			$self->manage_db_error($dbh,"work_table_to_file");
         return undef;
      }

      my $fdata1="$Crawler::MDATA_PATH/input/idx/\.$idx\.info";
      my $fdata2="$Crawler::MDATA_PATH/input/idx/$idx\.info";
$self->log('debug',"work_table_to_file:: FILE=$fdata1");
      open (F,">$fdata1");
      foreach my $l (@$rres) {
         my $host_name=$l->[1].'.'.$l->[2];
			my $subtable=sprintf("%03d", $l->[18]);
         my %h=('host_ip'=>$l->[0], 'host_name'=>$host_name, 'hname'=>$l->[1], 'hdomain'=>$l->[2], 'iddev'=>$l->[3], 'idmetric'=>$l->[4], 'iid'=>$l->[5], 'cause'=>$l->[6], 'mode'=>$l->[7], 'module'=>$l->[8], 'monitor'=>$l->[9], 'mtype'=>$l->[10], 'name'=>$l->[11], 'severity'=>$l->[12], 'type'=>$l->[13], 'subtype'=>$l->[14], 'watch'=>$l->[15], 'monitor_data'=>$l->[16], 'file'=>$l->[17], 'subtable'=>$subtable, 'status'=>$l->[19], 'top_value'=>$l->[20], 'cid'=>$l->[21]);

         print F encode_json(\%h). "\n";
      }
      close F;
		my $rx=copy($fdata1,$fdata2);
      if (! $rx) {
         $self->log('warning',"work_table_to_file:: **ERROR AL MOVER FICHERO** ($!) $fdata1->$fdata2");
      }
		unlink $fdata1;
	}

   #---------------------------------------------------------
   # xagent
   #---------------------------------------------------------
   elsif ($table eq 'work_xagent') {

      $rres=sqlSelectAll($dbh,'ip,name,domain,id_dev,id_metric,iid,cause,mode,module,watch as monitor,mtype,mname,severity,type,subtype,watch,version,get_iid,script,params,nparams,class,items,cfg,custom,id_proxy,file,subtable,status,cid,tag,esp,proxy_type,proxy_user,timeout,top_value',"cnm.$table","crawler_idx=$crawler_idx",'');


#cfg=1 _o&o_ class=proxy-linux _o&o_ custom=0 _o&o_ file=0000000013/xagt_004000-STD.rrd _o&o_ get_iid=0 _o&o_ hash=385008e4e77ef7d975285b5cd606925f _o&o_ host_ip=10.2.254.220 _o&o_ host_name=server1 _o&o_ id_proxy=3 _o&o_ iddev=13 _o&o_ idmetric=2427 _o&o_ iid=ALL _o&o_ items=Time _o&o_ label=CADUCIDAD DE UN CERTIFICADO SSL (server1.s30labs.com) _o&o_ lapse=300 _o&o_ max=  _o&o_ mode=GAUGE _o&o_ module=mod_xagent_get _o&o_ mtype=STD_AREA _o&o_ name=xagt_004000 _o&o_ nparams=1 _o&o_ params=[;Puerto;443] _o&o_ script=linux_metric_certificate_expiration_time.pl _o&o_ severity=2 _o&o_ subtype=xagt_004000 _o&o_ type=xagent _o&o_ watch=0


      $self->error($libSQL::err);
      $self->errorstr($libSQL::errstr);
      $self->lastcmd($libSQL::cmd);

      if ($libSQL::err) {
         #$self->log('warning',"work_table_to_file::[DBERROR] (EDB=$libSQL::err) $libSQL::errstr ($libSQL::cmd)");
			$self->manage_db_error($dbh,"work_table_to_file");
         return undef;
      }

		my %scripts=();
      my $fdata1="$Crawler::MDATA_PATH/input/idx/\.$idx\.info";
      my $fdata2="$Crawler::MDATA_PATH/input/idx/$idx\.info";
$self->log('debug',"work_table_to_file:: FILE=$fdata1");
      open (F,">$fdata1");
      foreach my $l (@$rres) {
         my $host_name=$l->[1].'.'.$l->[2];
			my $subtable=sprintf("%03d", $l->[27]);
         my %h=('host_ip'=>$l->[0], 'host_name'=>$host_name, 'hname'=>$l->[1], 'hdomain'=>$l->[2], 'iddev'=>$l->[3], 'idmetric'=>$l->[4], 'iid'=>$l->[5], 'cause'=>$l->[6], 'mode'=>$l->[7], 'module'=>$l->[8], 'watch'=>$l->[9], 'mtype'=>$l->[10], 'name'=>$l->[11], 'severity'=>$l->[12], 'type'=>$l->[13], 'subtype'=>$l->[14], 'watch'=>$l->[15], 'version'=>$l->[16], 'get_iid'=>$l->[17], 'script'=>$l->[18], 'params'=>$l->[19], 'nparams'=>$l->[20],  'class'=>$l->[21], 'items'=>$l->[22], 'cfg'=>$l->[23], 'custom'=>$l->[24], 'id_proxy'=>$l->[25],  'file'=>$l->[26], 'subtable'=>$subtable, 'status'=>$l->[28], 'cid'=>$l->[29], 'tag'=>$l->[30], 'esp'=>$l->[31], 'proxy_type'=>$l->[32], 'proxy_user'=>$l->[33], 'timeout'=>$l->[34], 'top_value'=>$l->[35]);

         print F encode_json(\%h). "\n";

			$scripts{$l->[18]}=1;
      }
      close F;

		#-----------------------------------------
		# Se guardan los scripts en el directorio adecuado para los crawlers
		foreach my $s (keys %scripts) {
			$self->script2file($dbh,$s);
		}
		#-----------------------------------------

      my $rx=copy($fdata1,$fdata2);
      if (! $rx) {
         $self->log('warning',"work_table_to_file:: **ERROR AL MOVER FICHERO** ($!) $fdata1->$fdata2");
      }
		unlink $fdata1;
   }

}

#----------------------------------------------------------------------------
# Funcion: clean_idx_files 
#----------------------------------------------------------------------------
# Descripcion: Elimina ficheros idx de mdata que ya no sean necesarios porque
# se necesitan menos crawlers.
#-----------------------------------------------------------------------------
sub clean_idx_files {
my ($self,$crawler_idx)=@_;

	my $do_clean=1;
	while ($do_clean) {
		$crawler_idx+=1;
		my $idx = sprintf("%05d", $crawler_idx);
		my $fdata="$Crawler::MDATA_PATH/input/idx/$idx\.info";
		if (-f $fdata) {
			my $rx=unlink $fdata;
         $self->log('info',"clean_idx_files:: Eliminado $fdata ($rx)");
		}
		else { $do_clean=0; }
	}
}

#-----------------------------------------------------------------------------
sub scripts2cache {
my ($self,$dbh,$range)=@_;

	my $dir_scripts='/opt/data/mdata/scripts';
   #my $rres=sqlSelectAll($dbh,'distinct script',"cnm.work_xagent",'','');
#select script, count(*) as cnt FROM cnm.work_xagent WHERE crawler_idx=6011 GROUP BY script ORDER BY cnt desc;
	my $rres=sqlSelectAll($dbh,'script, count(*) as cnt','cnm.work_xagent',"crawler_idx=$range",'GROUP BY script ORDER BY cnt desc');
   foreach my $l (@$rres) {
		my $script = $l->[0];
		my $cnt = $l->[1];
		if ($script=~/^\w*/) {  
      	$self->log('info',"scripts2cache_ok:: $script ($cnt)");
			$self->script2file($dbh,$script); 
			my $fscript = join('/', $dir_scripts, $script);
			my $fscript_range = join('.', $fscript, $range);
			my $rx=copy($fscript,$fscript_range);
			my $uid = getpwnam 'root';
			my $gid = getgrnam 'www-data';
			chown $uid, $gid, $fscript_range;
			chmod 0775, $fscript_range;
		}
	}
}

#-----------------------------------------------------------------------------
sub script2file {
my ($self,$dbh,$script)=@_;

	my $dir_scripts='/opt/data/mdata/scripts';
   if (! -d $dir_scripts) { 
		mkdir $dir_scripts,0775; 
		system("/bin/chown root:www-data $dir_scripts");
	}

  	my $rres=sqlSelectAll($dbh,'script_data','cfg_monitor_agent_script',"script=\'$script\'",'');
   $self->error($libSQL::err);
   $self->errorstr($libSQL::errstr);
   $self->lastcmd($libSQL::cmd);

   if ($libSQL::err) {
      $self->log('warning',"script2file::[DBERROR] (EDB=$libSQL::err) $libSQL::errstr ($libSQL::cmd)");
		$self->manage_db_error($dbh,"script2file");
      return undef;
   }

   my $fscript=$dir_scripts.'/'.$script;

   my $rc = open my $fh, '>:encoding(UTF-8)', $fscript;
	if (! $rc) { 
		$self->log('warning',"script2file:: ERROR AL COPIAR SCRIPT $fscript ($!)");
		return undef;
	}
   print $fh $rres->[0][0]."\n";
   close $fh;
	$self->log('debug',"script2file:: ++++++ COPIADO SCRIPT $fscript rc=$rc");
   chmod 0775, $fscript;
	system ("/bin/chown -R root:www-data $fscript");	
}


#-----------------------------------------------------------------------------
# get_device_credentials
#-----------------------------------------------------------------------------
# Obtiene las credenciales de un dispositivo caracterizado por su ip o su id_dev
# y actualiza las variables adecuadas.
sub get_device_credentials {
my ($self,$dbh,$desc)=@_;

	my $rres;
	my %vars =();
	my $condition='';
	if (exists $desc->{'id_dev'}) {
		my $id_dev = $desc->{'id_dev'};
		$condition="AND id_dev=$id_dev";
	}
	elsif (exists $desc->{'ip'}) {
		my $ip=$desc->{'ip'};
		$condition=" AND ip=\'$ip\'";
   }

   $rres=sqlSelectAll($dbh,'d.id_dev,d.ip,c.type,c.user,c.pwd,c.port','credentials c, device2credential b, devices d',"d.id_dev=b.id_dev AND c.id_credential=b.id_credential $condition",'');
	$self->log('debug',"get_device_credentials:: SQL=$libSQL::cmd");

   $self->error($libSQL::err);
   $self->errorstr($libSQL::errstr);
   $self->lastcmd($libSQL::cmd);

   if ($libSQL::err) {
      $self->manage_db_error($dbh,"get_device_credentials");
      return \%vars;
   }

   foreach my $l (@$rres) {
		#$cred.type.name
		my $var_user = '$sec.'.$l->[2].'.user';
		my $var_pwd = '$sec.'.$l->[2].'.pwd';
		my $var_port = '$sec.'.$l->[2].'.port';
		my $ip = $l->[1];

		if (! exists $vars{$ip})  {  
			$vars{$ip} = {$var_user=>$l->[3], $var_pwd=>$l->[4], $var_port=>$l->[5]};
		}
		else {
			$vars{$ip}{$var_user} = $l->[3];
			$vars{$ip}{$var_pwd} = $l->[4];
			$vars{$ip}{$var_port} = $l->[5];
		}
#		$vars{$var_user}=$l->[3];
#		$vars{$var_pwd}=$l->[4];
#		$vars{$var_port}=$l->[5];
	}

	return \%vars;
}



#-----------------------------------------------------------------------------
# get_credential_info
#-----------------------------------------------------------------------------
# Obtiene los datos de una credencial a partir de su id
# Si no se especifica id devuelve todas
sub get_credential_info {
my ($self,$dbh,$desc)=@_;

   my @condition=();
   if (exists $desc->{'id_credential'}) {
      my $id_credential = $desc->{'id_credential'};
      push @condition, "id_credential=$id_credential";
   }
   if (exists $desc->{'type'}) {
      my $type = $desc->{'type'};
      push @condition, "type='$type'";
   }


   my %data=();
   my $sql='SELECT id_credential,name,descr,type,user,pwd,scheme,port FROM credentials';
	if (scalar(@condition) > 0) {$sql .= ' WHERE '. join(' AND ', @condition); }
   my $rres=sqlSelectAllCmd($dbh,$sql,'id_credential');
   $self->log('info',"get_credential_info:: SQL=$libSQL::cmd");

   $self->error($libSQL::err);
   $self->errorstr($libSQL::errstr);
   $self->lastcmd($libSQL::cmd);

   if ($libSQL::err) {
      $self->manage_db_error($dbh,"get_credential_info");
      return [];
   }

   return $rres;

}

#----------------------------------------------------------------------------
# Funcion: get_crawler_task
#----------------------------------------------------------------------------
# Descripcion: Obtiene el vector de tareas concreta para cada crawler.
# Necesita el crawler_idx y el type (porque el query es distinto)
# Se supone que las metricas deben estar registradas ==> existe crawler_idx
# Si no fuera asi, las metricas que no tengan crawler_idx no funcionarian
# Notar que los crawler_idx pueden corresponder a diferentes hosts (donde
# residan los crawlers), pero como el idx es unico no hay mayor problema.
#
# snmp:
# d.name,d.ip,m.name,m.type,m.mtype,m.mode,m.module,m.file,c.community,c.oid,c.version,a.watch,m.id_metric,d.id_dev,m.top_value,t.get_iid,m.severity,m.host
# latency:
# d.name,d.ip,m.name,m.type,m.mtype,m.mode,m.module,m.file,c.monitor,c.monitor_data,m.watch,m.id_metric,d.id_dev,m.top_value,m.severity,m.host
# xagent:
# d.name,d.ip,m.name,m.type,m.mtype,m.mode,m.module,m.file,c.monitor,c.monitor_data,m.watch,m.id_metric,d.id_dev,m.top_value,m.severity,m.host
# wbem:
# d.name,d.ip,m.name,m.type,m.mtype,m.mode,m.module,m.file,d.wbem_user,d.wbem_pwd,t.class,t.property,m.watch,m.id_metric,d.id_dev,m.top_value,t.get_iid,m.severity,m.host,m.iid,t.namespace
#-----------------------------------------------------------------------------
sub get_crawler_task {
my ($self,$dbh,$type,$lapse,$crawler_idx,$idm2host)=@_;
my $rres=undef;
my ($what,$from,$where);


	if ($type eq 'snmp') {
	   $what='d.name,d.ip,m.name,m.type,m.mtype,m.mode,m.module,m.file,d.community,c.oid,d.version,m.watch,m.id_metric,d.id_dev,m.top_value,t.get_iid,m.severity,m.host,t.cfg,m.label,m.subtype,m.iid';
   	$from='devices d,metrics m, metric2snmp c, cfg_monitor_snmp t';
     	$where="d.status=0 and m.status=0 and m.type='snmp' and d.id_dev=m.id_dev and m.id_metric=c.id_metric and m.subtype=t.subtype and m.lapse=$lapse ";
	}
	elsif ($type eq 'latency') {
	   $what='d.name,d.ip,m.name,m.type,m.mtype,m.mode,m.module,m.file,c.monitor,c.monitor_data,m.watch,m.id_metric,d.id_dev,m.top_value,m.severity,m.host,m.label,m.subtype,m.iid';
   	$from='devices d,metrics m, metric2latency c';
      $where="d.status=0 and m.status=0 and m.type='latency' and d.id_dev=m.id_dev and m.id_metric=c.id_metric and m.lapse=$lapse ";
	}
   elsif ($type eq 'xagent') {
	   $what='d.name,d.ip,m.name,m.type,m.mtype,m.mode,m.module,m.file,c.script,c.params,m.watch,m.id_metric,d.id_dev,m.top_value,m.severity,m.host,m.label,c.nparams,c.class,c.items,c.cfg,c.custom,m.subtype,m.iid,c.get_iid,c.id_proxy';
   	$from='devices d,metrics m, cfg_monitor_agent c';
      $where="d.status=0 and m.status=0 and m.type='xagent' and d.id_dev=m.id_dev and c.subtype=m.subtype and c.id_proxy=0 and m.lapse=$lapse ";
   }
   elsif ($type eq 'xagent-proxy') {
      $what='d.name,d.ip,m.name,m.type,m.mtype,m.mode,m.module,m.file,c.script,c.params,m.watch,m.id_metric,d.id_dev,m.top_value,m.severity,m.host,m.label,c.nparams,c.class,c.items,c.cfg,c.custom,m.subtype,m.iid,c.get_iid,c.id_proxy,c.script';
      $from='devices d,metrics m, cfg_monitor_agent c';
      $where="d.status=0 and m.status=0 and m.type='xagent' and d.id_dev=m.id_dev and c.subtype=m.subtype and c.id_proxy!=0 and m.lapse=$lapse ";
   }
   elsif ($type eq 'wbem') {
      $what='d.name,d.ip,m.name,m.type,m.mtype,m.mode,m.module,m.file,d.wbem_user,d.wbem_pwd,t.class,t.property,m.watch,m.id_metric,d.id_dev,m.top_value,t.get_iid,m.severity,m.host,m.iid,t.namespace,t.cfg,m.label,m.subtype,m.iid';
      $from='devices d,metrics m, cfg_monitor_wbem t';
      $where="d.status=0 and m.status=0 and m.type='wbem' and d.id_dev=m.id_dev and m.subtype=t.subtype and m.lapse=$lapse ";
   }
	else {
		$self->log('warning',"get_crawler_task ($type)::[WARN] TYPE NO CONTEMPLADO");
		return $rres;
	}

	my $other='order by m.id_dev';
	if ($crawler_idx) { $where .= " and  m.crawler_idx=$crawler_idx "; }

	if ($type eq 'xagent-proxy') { $other='order by c.id_proxy'; }
	elsif ($crawler_idx) { $other='order by d.name'; }


   if (! defined $dbh) {
      $self->log('warning',"get_crawler_task ($type|$crawler_idx)::[WARN] DBH = UNDEF");
      $dbh=$self->open_db();
	   if ($libSQL::err) {
   	   $self->log('warning',"get_crawler_task ($type|$crawler_idx)::[WARN] (EDB=$libSQL::err) $libSQL::errstr ($libSQL::cmd)");
      	$self->close_db($dbh);
      	$dbh=$self->open_db();
   	}
	}

   $rres=sqlSelectAll($dbh,$what,$from,$where,$other);
   $self->error($libSQL::err);
   $self->errorstr($libSQL::errstr);
   $self->lastcmd($libSQL::cmd);

   if ($libSQL::err) {
      #$self->log('warning',"get_crawler_task ($type|$crawler_idx)::[ERROR] En select (EDB=$libSQL::err) $libSQL::errstr ($libSQL::cmd)");
		$self->manage_db_error($dbh,"get_crawler_task");
		#return $rres;
		return undef;
   }



#$self->log('warning',"get_crawler_task ($type|$crawler_idx)::**FML register**** (EDB=$libSQL::err) $libSQL::errstr ($libSQL::cmd)");

	if ((scalar @$rres) == 0) { return undef; }

	# Se compone el hash %$idm2host (IDM2HOST) que agrupa las metricas por host (gestor)

	# -----------------------------------------------------------------------------------------------------
	# snmp
	# -----------------------------------------------------------------------------------------------------
	#  0      1    2      3      4       5      6        7      8           9     10        11      12          13       14          15         16        17    18     19     20		   21
	# d.name,d.ip,m.name,m.type,m.mtype,m.mode,m.module,m.file,d.community,c.oid,d.version,m.watch,m.id_metric,d.id_dev,m.top_value,t.get_iid,m.severity,m.host,t.cfg,m.label,m.subtype,m.iid
   if ($type eq 'snmp') {

   	foreach my $l (@$rres) {

      	my $get_iid= ($l->[15] ne '') ? 1 : 0;
      	my $w = (defined $l->[11]) ? $l->[11] : 0;
      	my $hash1=join(',',$l->[0],$l->[1],$l->[2],$l->[3],$l->[4],$l->[5],$l->[6],$lapse,$l->[8],$l->[9],$l->[11],$l->[10],$w,$get_iid,$l->[16],$l->[19]);
			my $hash=md5_hex($hash1);
      	my $h=$l->[17];
      	if ($h) {

         	push @{$idm2host->{$h}}, {  host_name => $l->[0], host_ip => $l->[1], name => $l->[2],
                                    type => $l->[3], mtype => $l->[4], mode => $l->[5],
                                    module => $l->[6], lapse => $lapse, file=> $l->[7],
                                    community => $l->[8], oid => $l->[9], version => $l->[10],
                                    watch => $w, idmetric=>$l->[12], iddev=>$l->[13], max=>$l->[14],
                                    get_iid=>$get_iid, severity=>$l->[16], cfg=>$l->[18],
												label=>$l->[19], subtype=>$l->[20], iid=>$l->[21], hash=>$hash } ;
      	}

#      	else {
#
#         	push @idm, {  host_name => $l->[0], host_ip => $l->[1], name => $l->[2],
#                        type => $l->[3], mtype => $l->[4], mode => $l->[5],
#                        module => $l->[6], lapse => $lapse, file=> $l->[7],
#                        community => $l->[8], oid => $l->[9], version => $l->[10],
#                        watch => $w, idmetric=>$l->[12], iddev=>$l->[13], max=>$l->[14],
#                        get_iid=>$get_iid, severity=>$l->[16], hash=>$hash } ;
#      	}


	  	}
	}
	# -----------------------------------------------------------------------------------------------------
	# latency
	# -----------------------------------------------------------------------------------------------------
	#   0     1     2     3       4       5      6        7      8         9              10      11          12         13         14         15     16    17		  18
	# d.name,d.ip,m.name,m.type,m.mtype,m.mode,m.module,m.file,c.monitor,c.monitor_data,m.watch,m.id_metric,d.id_dev,m.top_value,m.severity,m.host,m.label,m.subtype,m.iid
	elsif ($type eq 'latency') {

	   foreach my $l (@$rres) {

   	   my %mdata=();
      	if ($l->[9]) {
         	my @kv=split(/\|/,   $l->[9]);
	         foreach my $kv (@kv) {
   	         #my ($k,$v)=split('=',$kv);
      	      #if ((defined $k) && (defined $v)) { $mdata{$k}=$v; }
					#El split no funcionaria en metricas tipo ldap donde los valores contienen '='  
					if ($kv =~ /^\s*(\w+)\s*\=\s*(.+)$/) { $mdata{$1}=$2; }
         	}
      	}

	      my $w = (defined $l->[10]) ? $l->[10] : 0;
   	   my $md = (defined $l->[9]) ? $l->[9] : 0;
      	my $hash1= join(',',$l->[0],$l->[1],$l->[2],$l->[3],$l->[4],$l->[5],$l->[6],$lapse,$l->[8],$md,$w,$l->[14],$l->[16]);
			my $hash=md5_hex($hash1);
	      my $h=$l->[15];
   	   if ($h) {

      	   push @{$idm2host->{$h}}, { host_name => $l->[0], host_ip => $l->[1], name => $l->[2],
         	                        type => $l->[3], mtype => $l->[4], mode => $l->[5],
                  	               module => $l->[6], lapse => $lapse, monitor => $l->[8],
            		                  file=> $l->[7], watch => $w, idmetric=>$l->[11],
                     	            iddev=>$l->[12], max => $l->[13], severity=>$l->[14],
												label=>$l->[16], subtype=>$l->[17], iid=>$l->[18],  hash=>$hash, %mdata };


      	}
#      	else {
#
#         	push @idm, { host_name => $l->[0], host_ip => $l->[1], name => $l->[2],
#            	           type => $l->[3], mtype => $l->[4], mode => $l->[5],
#               	        module => $l->[6], lapse => $lapse, monitor => $l->[8],
#                  	     file=> $l->[7], watch => $w, idmetric=>$l->[11],
#                     	  iddev=>$l->[12], max => $l->[13], severity=>$l->[14], hash=>$hash, %mdata };
#      	}

   	}
	}

	# -----------------------------------------------------------------------------------------------------
	# xagent
	# -----------------------------------------------------------------------------------------------------
	#  0      1     2      3      4      5       6        7      8        9       10       11        12         13         14         15     16        17       18     19     20   21		  22		  23    24         25
	#d.name,d.ip,m.name,m.type,m.mtype,m.mode,m.module,m.file,c.script,c.params,m.watch,m.id_metric,d.id_dev,m.top_value,m.severity,m.host,m.label,c.nparams,c.class,c.items,c.cfg,c.custom,m.subtype,m.iid,c.get_iid,c.id_proxy
	elsif ($type eq 'xagent') {

	   foreach my $l (@$rres) {

   	   my %mdata=();
      	if ($l->[9]) {
         	my @kv=split(/\|/,   $l->[9]);
	         foreach my $kv (@kv) {
   	         # OJO! Si hay valores del tipo:
      	      # params=cmd=cscript c:\xagent\random.vbs //Nologo                                                                                      # El split no funcionaria
         	   if ($kv =~ /^\s*(\S+)\s*\=\s*(.+)$/) { $mdata{$1}=$2; }
            	#my ($k,$v)=split('=',$kv);
	            #if ((defined $k) && (defined $v)) { $mdata{$k}=$v; }
   	      }
      	}

	      my $md = (defined $l->[9]) ? $l->[9] : 0;
   	   my $w = (defined $l->[10]) ? $l->[10] : 0;
      	my $hash1 = join(',',$l->[0],$l->[1],$l->[2],$l->[3],$l->[4],$l->[5],$l->[6],$lapse,$l->[8],$md,$w,$l->[14],$l->[16],$l->[25]);
			my $hash=md5_hex($hash1);
	      my $h=$l->[15];

   	   if ($h) {

      	   push @{$idm2host->{$h}}, { host_name => $l->[0], host_ip => $l->[1], name => $l->[2],
         	                        type => $l->[3], mtype => $l->[4], mode => $l->[5],
            	                     module => $l->[6], lapse => $lapse, script => $l->[8],
               	                  file=> $l->[7], watch => $l->[10], idmetric=>$l->[11], iddev=>$l->[12],
			 									max => $l->[13], severity=>$l->[14], params=>$l->[9], label=>$l->[16], nparams=>$l->[17] ,
												class=>$l->[18], items=>$l->[19], cfg=>$l->[20], custom=>$l->[21],
												subtype=>$l->[22],  iid=>$l->[23], get_iid=>$l->[24], id_proxy=>$l->[25], hash=>$hash, %mdata };
      	}

#	      else {
#	
#   	      push @idm, { host_name => $l->[0], host_ip => $l->[1], name => $l->[2],
#      	               type => $l->[3], mtype => $l->[4], mode => $l->[5],
#         	            module => $l->[6], lapse => $lapse, monitor => $l->[8],
#            	         file=> $l->[7], watch => $l->[10], idmetric=>$l->[11], iddev=>$l->[12],
#               	      max => $l->[13], severity=>$l->[14], params=>$l->[9], hash=>$hash, %mdata };
#      	}


   	}

	}


   # -----------------------------------------------------------------------------------------------------
   # xagent
   # -----------------------------------------------------------------------------------------------------
   #  0      1     2      3      4      5       6        7      8        9       10       11        12         13         14         15     16        17       18     19     20   21        22       23    24         25		   26
   #d.name,d.ip,m.name,m.type,m.mtype,m.mode,m.module,m.file,c.script,c.params,m.watch,m.id_metric,d.id_dev,m.top_value,m.severity,m.host,m.label,c.nparams,c.class,c.items,c.cfg,c.custom,m.subtype,m.iid,c.get_iid,c.id_proxy,c.script
   elsif ($type eq 'xagent-proxy') {

      foreach my $l (@$rres) {

         my %mdata=();
         if ($l->[9]) {
            my @kv=split(/\|/,   $l->[9]);
            foreach my $kv (@kv) {
               # OJO! Si hay valores del tipo:
               # params=cmd=cscript c:\xagent\random.vbs //Nologo                                                                                      # El split no funcionaria
               if ($kv =~ /^\s*(\S+)\s*\=\s*(.+)$/) { $mdata{$1}=$2; }
               #my ($k,$v)=split('=',$kv);
               #if ((defined $k) && (defined $v)) { $mdata{$k}=$v; }
            }
         }

         my $md = (defined $l->[9]) ? $l->[9] : 0;
         my $w = (defined $l->[10]) ? $l->[10] : 0;
         my $hash1 = join(',',$l->[0],$l->[1],$l->[2],$l->[3],$l->[4],$l->[5],$l->[6],$lapse,$l->[8],$md,$w,$l->[14],$l->[16],$l->[25]);
         my $hash=md5_hex($hash1);
         my $h=$l->[15];

         if ($h) {

            push @{$idm2host->{$h}}, { host_name => $l->[0], host_ip => $l->[1], name => $l->[2],
                                    type => $l->[3], mtype => $l->[4], mode => $l->[5],
                                    module => $l->[6], lapse => $lapse, script => $l->[8],
                                    file=> $l->[7], watch => $l->[10], idmetric=>$l->[11], iddev=>$l->[12],
                                    max => $l->[13], severity=>$l->[14], params=>$l->[9], label=>$l->[16], nparams=>$l->[17] ,
                                    class=>$l->[18], items=>$l->[19], cfg=>$l->[20], custom=>$l->[21],
                                    subtype=>$l->[22],  iid=>$l->[23], get_iid=>$l->[24], id_proxy=>$l->[25],
												script=>$l->[26],  hash=>$hash, %mdata };
         }
		}
	}

	# -----------------------------------------------------------------------------------------------------
	# wbem
	# -----------------------------------------------------------------------------------------------------
	# 0       1    2      3      4       5      6        7      8           9          10      11         12       13          14       15         16        17         18		19		20         21     22     23		  24
	# d.name,d.ip,m.name,m.type,m.mtype,m.mode,m.module,m.file,d.wbem_user,d.wbem_pwd,m.class,m.property,m.watch,m.id_metric,d.id_dev,m.top_value,t.get_iid,m.severity,m.host,m.iid,t.namespace,t.cfg,m.label,m.subtype,m.iid
   if ($type eq 'wbem') {

      foreach my $l (@$rres) {

			# Si no existe el usuario y la pwd wbem. No se puede provisionar.
			if ( (! $l->[8]) || (! $l->[9]) ) {
				$self->log('warning',"get_crawler_task ($type)::[WARN] NO DEFINIDO USER/PWD EN $l->[0] ($l->[1])");
				next;
			}

         #my $get_iid= ($l->[16] ne '') ? 1 : 0;
         my $max= (defined $l->[15]) ? $l->[15] : 1;
         my $w = (defined $l->[12]) ? $l->[12] : 0;
         my $hash1=join(',',$l->[0],$l->[1],$l->[2],$l->[3],$l->[4],$l->[5],$l->[6],$lapse,$l->[8],$l->[9],$l->[11],$l->[10],$w,$l->[16],$l->[22]);
			my $hash=md5_hex($hash1);
         my $h=$l->[18];

         if ($h) {

            push @{$idm2host->{$h}}, {  host_name => $l->[0], host_ip => $l->[1], name => $l->[2],
                                    type => $l->[3], mtype => $l->[4], mode => $l->[5],
                                    module => $l->[6], lapse => $lapse, file=> $l->[7],
                                    wbem_user => $l->[8], wbem_pwd => $l->[9], class => $l->[10], property => $l->[11],
                                    watch => $w, idmetric=>$l->[13], iddev=>$l->[14], max=>$max, namespace => $l->[20],
                                    get_iid=>$l->[16], severity=>$l->[17], iid=>$l->[19], cfg=>$l->[21],
												label=>$l->[22], subtype=>$l->[23],  iid=>$l->[24], hash=>$hash } ;
         }

#        else {
#
#           push @idm, {  host_name => $l->[0], host_ip => $l->[1], name => $l->[2],
#                        type => $l->[3], mtype => $l->[4], mode => $l->[5],
#                        module => $l->[6], lapse => $lapse, file=> $l->[7],
#                        community => $l->[8], oid => $l->[9], version => $l->[10],
#                        watch => $w, idmetric=>$l->[12], iddev=>$l->[13], max=>$l->[14],
#                        get_iid=>$get_iid, severity=>$l->[16], hash=>$hash } ;
#        }


      }
   }


   return $rres;
}


#----------------------------------------------------------------------------
# Funcion: get_crawler_task_from_work_file
#----------------------------------------------------------------------------
# Descripcion: Obtiene el vector de tareas concreta para un crawler.
# Necesita el crwler_idx y el type (porque cada tipo almacena valores diferentes)
#-----------------------------------------------------------------------------
sub get_crawler_task_from_work_file {
my ($self,$range,$type,$task)=@_;
my $IDX_PATH='/opt/data/idx';

   #DBG--
   $self->log('debug',"get_crawler_task_from_work_file::#RELOAD RANGE=$range TASK=$task");
   #/DBG--

	my $dir_idx="$Crawler::MDATA_PATH/input/idx";
   my $idx = sprintf("%05d", $range);
	my $ft=$dir_idx.'/'.$idx.'.info';

	if (! -f $ft) {
      $self->log('info',"get_crawler_task_from_work_file:: NO EXISTE $ft");
      return undef;
   }

   my $rc=open (F,"<$ft");
   if (! $rc) {
      $self->log('warning',"get_crawler_task_from_work_file::#RELOAD[WARN] ERROR AL ABRIR $ft ($!)");
      return undef;
   }

	# El contenido del fichero es del tipo k1=v1,k2=v2 .... por linea
	# Notar que hay parametros que pueden ser variables ( p. ej. en latency )
	@$task=();
	my %H=();
	while (my $line = <F>) {
		# Hay que garantizar que el separador es el esperado.
		# Si no fuera asi puede haber problemas al decodificar el json 
		local $/ = "\n";
		chomp $line;

		eval {
			my $h=decode_json($line);

			if ($type eq 'latency') {
      	   if ($h->{'monitor_data'}) {
         	   my @kv=split(/\|/,   $h->{'monitor_data'});
            	foreach my $kv (@kv) {
               	#OJO!! El split no funcionaria en metricas tipo ldap donde los valores contienen '='
	               if ($kv =~ /^\s*(\w+)\s*\=\s*(.+)$/) { $h->{$1}=$2; }
   	         }
      	   }
			}

			my $task_id=$h->{'host_ip'}.'-'.$h->{'name'};
			$H{$task_id}=$h;
			#push @$task, $h;
		};
		if ($@) { $self->log('warning',"get_crawler_task_from_work_file::**ERROR** al leer file=$ft ($line) ($@)"); }

	}
	close F;

	# Es fundamental que el vector de tareas se genere ordenado por task_id para no mezclar tareas 
	# distintas o de diferentes IPs que generen errores al usar la CACHE
	foreach my $k (sort keys %H) {
		push @$task,$H{$k}
	}

	return 1;
}


#----------------------------------------------------------------------------
# Funcion: get_crawler_task_from_file
#----------------------------------------------------------------------------
# Descripcion: Obtiene el vector de tareas concreta para un crawler.
# Necesita el crwler_idx y el type (porque cada tipo almacena valores diferentes)
#
# snmp:
# d.name,d.ip,m.name,m.type,m.mtype,m.mode,m.module,m.file,c.community,c.oid,c.version,a.watch,m.id_metric,d.id_dev,m.top_value,t.get_iid
# latency:
# d.name,d.ip,m.name,m.type,m.mtype,m.mode,m.module,m.file,c.monitor,c.monitor_data,m.watch,m.id_metric,d.id_dev,m.top_value
# xagent:
# d.name,d.ip,m.name,m.type,m.mtype,m.mode,m.module,m.file,c.monitor,c.monitor_data,m.watch,m.id_metric,d.id_dev,m.top_value
#-----------------------------------------------------------------------------
sub get_crawler_task_from_file {
my ($self,$range,$task)=@_;
my $IDX_PATH='/opt/data/idx';

   #DBG--
   $self->log('debug',"get_crawler_task_from_file::#RELOAD RANGE=$range TASK=$task");
   #/DBG--

   my $idx = sprintf("%04d", $range);
   #my $file_task=glob("$IDX_PATH/$idx\.*\.info");
   # OJO!! aqui el glob no funcionaba bien ????
   opendir (DIR,$IDX_PATH);
   my @file_task = grep { /$idx\.\w+\.info/ } readdir(DIR);
   closedir(DIR);

   if (! scalar @file_task) {
      $self->log('warning',"get_crawler_task_from_file::#RELOAD[WARN] No se encuentra fichero para IDX=$idx");
      return undef;
   }

   my $ft=$IDX_PATH.'/'.$file_task[0];
   my $rc=open (F,"<$ft");
   if (! $rc) {
      $self->log('warning',"get_crawler_task_from_file::#RELOAD[WARN] error al abrir $ft ($!)");
      return undef;
   }

   # El contenido del fichero es del tipo k1=v1,k2=v2 .... por linea
   # Notar que hay parametros que pueden ser variables ( p. ej. en latency )
   @$task=();
   while (<F>) {
      #my @pair=split(',',$_);
      my @pair=split($Crawler::SEPARATOR,$_);
      my %h=();
      foreach my $p (@pair) {
         # Hay que sustituirlo por un regex por el caso de params
         #my ($k,$v)= split(/\=/,$p);
         #$h{$k}=$v;
         $p=~/^(\S+?)\s*\=\s*(.*)$/;
         $h{$1}=$2;

         #my $kk=$1;
         #my $vv=$2;
         #if ($kk ne 'label') { $h{$kk}=$vv; }
      }
      push @$task, \%h;
   }

   close F;
   return 1;

}


#----------------------------------------------------------------------------
# Funcion: get_all_metrics_to_register
# Descripcion:
# m.id_metric
#----------------------------------------------------------------------------
sub get_all_metrics_to_register {
my ($self,$dbh,$lapse,$type)=@_;
my $rres;
my $retries=5;

   if ((! defined $lapse) || (! defined $type)) { return undef; }

 	my $host=$self->host();

	my $what='m.id_metric';
	my $from='devices d,metrics m';
   my $where="d.id_dev=m.id_dev and d.status=0 and m.host=\'$host\' and m.status=0 and m.lapse=$lapse and m.type=\'$type\'";

   do {
      if (! defined $dbh) {
         $self->log('warning',"get_all_metrics_to_register::[WARN] DBH = UNDEF");
         $dbh=$self->open_db();
      }

      if ($libSQL::err) {
         $self->log('warning',"get_all_metrics_to_register::[WARN] (EDB=$libSQL::err) $libSQL::errstr ($libSQL::cmd) (R=$retries)");
         $retries -=1;
         $self->close_db($dbh);
         $dbh=$self->open_db();
      }

		$rres=sqlSelectAll($dbh, $what, $from, $where);

   } while ( ($libSQL::err) && ($retries) );

   $self->error($libSQL::err);
   $self->errorstr($libSQL::errstr);
   $self->lastcmd($libSQL::cmd);

   if ($libSQL::err) {
      #$self->log('warning',"get_all_metrics_to_register::[ERROR] Superados reintentos (R=$retries) (EDB=$libSQL::err) $libSQL::errstr ($libSQL::cmd)");
		$self->manage_db_error($dbh,"get_all_metrics_to_register");
   }

   return $rres;
}


#----------------------------------------------------------------------------
# Funcion: get_crawler_task_descriptor
# Descripcion: Obtiene la informacion necesaria para que el crawler funcione
# m.crawler_idx,m.lapse,m.type
# OJO: Si host no esta bien puesto en el fichero de configuracion (es decir
# no coincide con el hostname) no obtiene tareas.
#----------------------------------------------------------------------------
sub get_crawler_task_descriptor {
my ($self,$dbh,$crawler_idx)=@_;
my ($where,$what);

   if (! defined $dbh) { return undef; }
	my $host=$self->host();
	my $table='metrics m,devices d';	

	if (! $crawler_idx) {
		$what='distinct m.crawler_idx,m.lapse,m.type';
   	$where="m.id_dev=d.id_dev and m.host=\'$host\' and d.status=0 and m.status=0 and m.crawler_idx is not null order by m.crawler_idx";
	}
	else {
		$what='m.crawler_idx,m.lapse,m.type';
		$where="m.id_dev=d.id_dev and m.host=\'$host\' and d.status=0 and m.status=0 and m.crawler_idx=$crawler_idx order by m.crawler_idx limit 1";
	}

   my $rres=sqlSelectAll($dbh, $what, $table, $where);

	if ( $libSQL::err ) { $self->log('warning',"get_crawler_task_descriptor::[WARN] Error en Select [$libSQL::err] $libSQL::errstr"); }
   return $rres;
}


#----------------------------------------------------------------------------
# Funcion: get_crawler_work_descriptors
# Descripcion: Devuelve una ref. a un hash con el mapeo de crawler_idx a tipos de crawlers.
# Utiliza las tablaswork_xxxx de cnm.
#----------------------------------------------------------------------------
sub get_crawler_work_descriptors {
my ($self,$dbh)=@_;
my ($where,$what);

   if (! defined $dbh) { return undef; }
   my $host=$self->host();
	my %mapping=();
	my $rres=sqlSelectAll($dbh, 'distinct crawler_idx,lapse', 'cnm.work_snmp', '');
	foreach my $l (@$rres) {  	$mapping{$l->[0]} = { 'lapse'=>$l->[1], 'type'=>'snmp'}; }

   $rres=sqlSelectAll($dbh, 'distinct crawler_idx,lapse', 'cnm.work_latency', '');
   foreach my $l (@$rres) {   $mapping{$l->[0]} = { 'lapse'=>$l->[1], 'type'=>'latency'}; }

   $rres=sqlSelectAll($dbh, 'distinct crawler_idx,lapse', 'cnm.work_xagent', '');
   foreach my $l (@$rres) {   $mapping{$l->[0]} = { 'lapse'=>$l->[1], 'type'=>'xagent'}; }

   return \%mapping;
}


#----------------------------------------------------------------------------
# Funcion: get_crawler_status
# Descripcion:
# Obtiene el estado que deberian tener los crawlers segun BD.
# OUTPUT:
# Ref. a un hash clave=idx valor=PID.
#----------------------------------------------------------------------------
sub get_crawler_status {
my ($self,$dbh)=@_;
my @idxs=();

   if (! defined $dbh) { return undef; }

   my $host=$self->host();

   my $what='distinct crawler_pid,crawler_idx';
   my $from='metrics m, devices d ';
   my $where="d.id_dev=m.id_dev and d.status=0 and m.status=0 and host=\'$host\'";
   my $rres=sqlSelectAll($dbh,$what,$from,$where);
   if ( $libSQL::err ) { $self->log('warning',"get_crawler_status::Error [$libSQL::err] $libSQL::errstr"); }
	my %out=();
	foreach my $l (@$rres) {
		if (! $l->[1]) {next;} #idx=0 no aporta nada
		my $idx=sprintf("%04d", $l->[1]);
		$out{$idx}=$l->[0];
	}
   return \%out;
}

#----------------------------------------------------------------------------
# Funcion: get_crawler_changes
# Descripcion:
# count(*)
# Revisa si ha habido modificaciones en las metricas que obliguen a redistribuir los
# procesos recolectores.
# Posibilidades
# 1. Metricas nuevas ==> crawler_idx=NULL
# 2. Metricas modificadas ==> refresh=1 (poner/quitar watches, modificar params en serv. IP etc.)
# 3. Metricas/Dispositivos con status modificado (alta -> baja,mant o baja,mant -> alta)
# 4. Metricas/Dispositivos eliminadas ==> tabla (del_devices/del_metrics)
# OUTPUT:
# El range que presenta cambios [crawler_idxi...] o crawler_idx
#----------------------------------------------------------------------------
sub get_crawler_changes {
my ($self,$dbh)=@_;
my @idxs=();
my $n=0;

   if (! defined $dbh) { return undef; }

   my $host=$self->host();

	#Metricas nuevas (no tienen asociado crawler_idx) -----------------------------	
	#Ahora se reinician todos los crawlers (esto habria que pulirlo)

	my $what='count(*)';
	my $from='metrics m,devices d';
   my $where="m.id_dev=d.id_dev and m.crawler_idx is NULL and  m.host=\'$host\' and m.name not like 'Spec%' and d.status=0 and m.status=0";
   my $rres=sqlSelectAll($dbh,$what,$from,$where);
   if ( $libSQL::err ) { $self->log('warning',"get_crawler_changes(cnm-watch)::Error S [$libSQL::err] $libSQL::errstr"); }
	$self->log('debug',"get_crawler_changes(cnm-watch):: NUEVAS=$rres->[0][0]");
	if ($rres->[0][0]) { return $rres->[0][0]; }

   #Metricas modificadas (refresh=1, d.status=0, m.status=0) ---------------------
	#a. d.status=0, m.status=0 => Siguen existiendo pero modificadas ==> restart crawler_idx's
	#b. d.status!=0 || m.status!=0 => Baja, Mantenimiento, borradas  ==> restart crawler_idx's

   $what='distinct m.crawler_idx';
   $from='metrics m,devices d';
   #$where="m.id_dev=d.id_dev and m.refresh=1 and m.host=\'$host\' and d.status=0 and m.status=0";
   $where="m.id_dev=d.id_dev and m.crawler_idx is not NULL and m.refresh=1 and m.host=\'$host\'";
   $rres=sqlSelectAll($dbh,$what,$from,$where);
   if ( $libSQL::err ) { $self->log('warning',"get_crawler_changes(cnm-watch)::Error S [$libSQL::err] $libSQL::errstr"); }
	$n=scalar @$rres;
	$self->log('debug',"get_crawler_changes(cnm-watch):: MODIFICADAS=$n (refresh=1,x.status=0)");
	
   foreach my $l (@$rres) { push @idxs, $l->[0]; }


   #Metricas eliminadas (refresh=1, status=3) ------------------------------------
	#a. Dispositivo eliminado ==> delete del device + update metrics (r=1,s=3)
	#b. Metrica eliminada ==> update metric (r=1,s=3)
	# ACCIONES: Borrar entradas de metrics + ficheros .rrd.
	#				Reitera el borrado de alerts y alerts_store (si hubiera)

   $what='file,id_dev,name,crawler_idx';
   $from='metrics';
   $where="refresh=1 and host=\'$host\' and status=3";
	$rres=sqlSelectAll($dbh,$what,$from,$where);
   if ( $libSQL::err ) { $self->log('warning',"get_crawler_changes(cnm-watch)::Error D (1) [$libSQL::err] $libSQL::errstr"); }
	if ($n=scalar @$rres) {
		sqlDelete($dbh,$from,$where);
		if ( $libSQL::err ) { $self->log('warning',"get_crawler_changes(cnm-watch)::Error D (2) [$libSQL::err] $libSQL::errstr"); }
	}
	$self->log('debug',"get_crawler_changes(cnm-watch):: ELIMINADAS=$n (refresh=1,x.status=3)");
	foreach my $l (@$rres) {
		push @idxs, $l->[3];

		my $rrd_file=$self->store_path().$self->store_subdir('elements').$l->[0];
		$self->log('info',"get_crawler_changes(cnm-watch):: unlink --> $rrd_file");
		unlink $rrd_file;

		my $id_device=$l->[1];
		my $mname=$l->[2];
	   my $f='alerts';
	   my $w="id_device=$id_device and mname=\'$mname\'";
		sqlDelete($dbh,$f,$w);
		$f='alerts_store';
		sqlDelete($dbh,$f,$w);
	}

   return \@idxs;
}


#----------------------------------------------------------------------------
# Funcion: reset_crawler_changes
# Descripcion:
#----------------------------------------------------------------------------
sub reset_crawler_changes  {
my ($self,$dbh,$idx)=@_;
my %table=(refresh=>0);
my $rv=undef;

   if (! defined $dbh) { return undef; }
   if (! defined $idx) { return undef; }

   my $host=$self->host();

	my $where = ($idx) ? "crawler_idx = \'$idx\' and host=\'$host\'"
							 : "host=\'$host\'";

   $rv=sqlUpdate($dbh,$TAB_METRICS_NAME,\%table,$where);
   if ( $libSQL::err ) {
		$self->log('warning',"reset_crawler_changes::Error en Update=[$libSQL::err] $libSQL::errstr ($libSQL::cmd)");
	}
}


#----------------------------------------------------------------------------
# Funcion: get_crawler_pid
# Descripcion:
# m.crawler_pid
#----------------------------------------------------------------------------
sub get_crawler_pid {
my ($self,$dbh,$crawler_idx)=@_;
my ($what,$where);

   if (! defined $dbh){ return undef; }

	my $host=$self->host();

	if (defined $crawler_idx)  {
		$what='crawler_pid';
		$where="host=\'$host\' and crawler_idx=$crawler_idx  limit 1";
	}
	else {
		$what='distinct crawler_pid';
		$where="host=\'$host\' and crawler_pid is not null";
	}

   my $rres=sqlSelectAll($dbh,
                        $what,
                        'metrics',
                        $where);
   return $rres;
}


#----------------------------------------------------------------------------
# Funcion: store_cfg_task_configured
# Crea una tarea para una aplicacion.
# Ejemplo:
#id_cfg_task_configured: 53
#                  name: ESCANEO DE SITEMA OPERATIVO
#                 descr:
#                  frec: U
#                  date: 1331506800
#                  cron: 00 00 12 03 * 2012
#                  task: app_tcp_scanso
#                  done: 1
#                  exec: 0
#                 atype: 12
#               subtype: app_tcp_scanso-9a1d059f
#                params:
# Necesarios:
# name,frec,date,cron,task,done,exec,atype,subtype
# name,frec,
#----------------------------------------------------------------------------
sub store_cfg_task_configured {
my ($self,$dbh,$aname,$name,$id_dev,$ip)=@_;
my $rv=undef;

	my $k=md5_hex(rand(1000000000));
   #------------------------------------------------------------------------
	my %data=();
	$data{'name'} = $name.' - ORIGINADA POR ALERTA';
   $data{'frec'} = 'U';
   $data{'date'} = time();
   $data{'cron'} = $self->time2cron($data{'date'});
   $data{'task'} = $aname;
   $data{'done'} = 0;
   $data{'exec'} = 1;
   $data{'atype'} = 0; #12
   $data{'subtype'} = $aname.'-'.substr $k,0,8;
   $data{'params'} = '';
	if ((! defined $name) || ($name eq '') ) { $data{'descr'} = $aname; }
   else { $data{'descr'} = $name; }

   #------------------------------------------------------------------------
   $rv=sqlInsertUpdate4x($dbh,'cfg_task_configured',\%data,\%data);
   $self->error($libSQL::err);
   $self->errorstr($libSQL::errstr);
   $self->lastcmd($libSQL::cmd);

   if ($libSQL::err) {
      #$self->log('warning',"store_cfg_task_configured::[WARN] ERROR $libSQL::err  en insert/update ($libSQL::cmd)");
		$self->manage_db_error($dbh,"store_cfg_task_configured");
      return undef;
   }

$self->log('info',"store_cfg_task_configured::**DEBUG** CMD=$libSQL::cmd");


	my $id = sqlLastInsertId($dbh,'cfg_task_configured','id_cfg_task_configured');
   if (! defined $id) {
      $self->log('warning',"store_cfg_task_configured:: err=$libSQL::err ($libSQL::errstr)");
      $id=-1;
   }

   $self->log('info',"store_cfg_task_configured:: INSERTADA TAREA $data{'subtype'} (ID=$id)");

   #------------------------------------------------------------------------
	my %data1=();
	$data1{'name'} = $data{'subtype'};
	$data1{'id_dev'} = $id_dev;
	$data1{'ip'} = $ip;
   $self->log('info',"store_cfg_task_configured:: VOY A INSERTAR en task2device name=$data1{'name'} ip=$ip id_dev=$id_dev");
   $rv=sqlInsertUpdate4x($dbh,'task2device',\%data1,\%data1);

$self->log('info',"store_cfg_task_configured::**DEBUG** CMD=$libSQL::cmd");
	return $id;
}


#----------------------------------------------------------------------------
# Funcion: get_cfg_notifications
# Descripcion: Obtiene los avisos definidos que estan asociados a algun dispositivo.
# Lo utiliza el modulo de gestion de avisos (avisos_manager) para procesarlos.
#
# SELECT c.id_cfg_notification,d.id_device,c.id_alert_type,r.id_notification_type,r.name,r.value,c.name,c.monitor,c.type from cfg_notifications c,  cfg_notification2device d, cfg_notification2transport t, cfg_register_transports r  where c.status=0 && c.id_cfg_notification=d.id_cfg_notification && c.id_cfg_notification=t.id_cfg_notification && t.id_register_transport=r.id_register_transport;
#
#----------------------------------------------------------------------------
sub get_cfg_notifications {
my ($self,$dbh)=@_;

   if (! defined $dbh) { return undef; }

   my $rres=sqlSelectAll(

		$dbh,
		'c.id_cfg_notification,d.id_device,c.id_alert_type,r.id_notification_type,r.value,c.name,c.monitor,c.type',
#     'c.id_cfg_notification,d.id_device,c.id_alert_type,c.id_notification_type,c.destino,c.name,c.monitor,c.type',
		'cfg_notifications c,  cfg_notification2device d, cfg_notification2transport t, cfg_register_transports r',
		'c.status=0 && c.id_cfg_notification=d.id_cfg_notification && c.id_cfg_notification=t.id_cfg_notification && t.id_register_transport=r.id_register_transport'
	);

   return $rres;

}


#----------------------------------------------------------------------------
# Funcion: get_notification2app
# Descripcion: Obtiene las aplicaciones asociadas a un determinado aviso.
#
# SELECT c.id_cfg_notification,d.id_device,c.id_alert_type,a.aname,a.name,c.name as nname,c.monitor,c.type FROM cfg_notifications c,  cfg_notification2device d, cfg_monitor_apps a, cfg_notification2app b WHERE c.status=0 && c.id_cfg_notification=d.id_cfg_notification && a.id_monitor_app=b.id_monitor_app
#----------------------------------------------------------------------------
sub get_notification2app {
my ($self,$dbh)=@_;

   if (! defined $dbh) { return undef; }

   my $rres=sqlSelectAll(

      $dbh,
      'c.id_cfg_notification,d.id_device,c.id_alert_type,a.aname,a.name,c.name as nname,c.monitor,c.type',
      'cfg_notifications c,  cfg_notification2device d, cfg_monitor_apps a, cfg_notification2app b',
      'c.status=0 && c.id_cfg_notification=d.id_cfg_notification && a.id_monitor_app=b.id_monitor_app'
   );

   return $rres;
}


#----------------------------------------------------------------------------
# Funcion: get_cfg_post_alert
# Obtiene los avisos y aplicaciones definidos
# En cfg_notifications:
# type: 		1 => Genera aviso al borrarse la alerta
# type_app: 1 => Ejecuta la app al borrarse la alerta
# type_run:	1 => Ejecutar inmediatamente
#----------------------------------------------------------------------------
sub get_cfg_post_alert {
my ($self,$dbh)=@_;

   if (! defined $dbh) { return undef; }

	my %data=();

	# --------------------------------------------------
	# Se obtienen los avisos
	# --------------------------------------------------
   my $rres=sqlSelectAll(

      $dbh,
      'c.id_cfg_notification,d.id_device,c.id_alert_type,r.id_notification_type,r.value,c.name,c.monitor,c.type,c.severity,c.wsize,c.template,c.title_template,r.calendar',
      'cfg_notifications c, cfg_notification2device d, cfg_notification2transport t, cfg_register_transports r',
      'c.status=0 AND c.id_cfg_notification=d.id_cfg_notification AND c.id_cfg_notification=t.id_cfg_notification AND t.id_register_transport=r.id_register_transport'
   );

   foreach my $l (@$rres) {
		my $id=$l->[0].'-'.$l->[1].'-'.$l->[4];
      $data{$id}= { 'id_dev'=>$l->[1], 'id_alert_type'=>$l->[2], 'id_notification_type'=>$l->[3], 'dest'=>$l->[4], 'nname'=>$l->[5], 'monitor'=>$l->[6], 'type'=>$l->[7], 'id_cfg_notification'=>$l->[0], 'severity'=>$l->[8], 'wsize'=>$l->[9], 'template'=>$l->[10], 'title_template'=>$l->[11], 'calendar'=>$l->[12], 'aviso'=>1 };
   }

	# --------------------------------------------------
	# Se obtienen las aplicaciones
	# En este caso type_app se almacena en type
	# --------------------------------------------------
   $rres=sqlSelectAll(

      $dbh,
      'c.id_cfg_notification,d.id_device,c.id_alert_type,a.aname,a.name,c.name as nname,c.monitor,c.type_app,c.type_run,a.script,a.params,s.timeout,c.severity,c.wsize,c.template,c.title_template',
      'cfg_notifications c,  cfg_notification2device d, cfg_monitor_apps a, cfg_notification2app b, cfg_monitor_agent_script s',
      'c.status=0 AND c.id_cfg_notification=d.id_cfg_notification AND a.id_monitor_app=b.id_monitor_app AND b.id_cfg_notification=c.id_cfg_notification AND a.script=s.script'
   );

   foreach my $l (@$rres) {
      my $id=$l->[0].'-'.$l->[1].'-'.$l->[4];

		#type_run != 0 => Se ejecuta inmediatamente
		if ($l->[8] != 0) {
	      $data{$id}= { 'id_dev'=>$l->[1], 'id_alert_type'=>$l->[2], 'aname'=>$l->[3], 'name'=>$l->[4], 'nname'=>$l->[5], 'monitor'=>$l->[6], 'type'=>$l->[7], 'id_cfg_notification'=>$l->[0], 'script'=>$l->[9], 'params'=>$l->[10], 'timeout'=>$l->[11], 'severity'=>$l->[12], 'wsize'=>$l->[13], 'template'=>$l->[14], 'title_template'=>$l->[15], 'calendar'=>'', 'run'=>1 };
		}
		#type_run == 0 => Se ejecuta como tarea
		else {
	      $data{$id}= { 'id_dev'=>$l->[1], 'id_alert_type'=>$l->[2], 'aname'=>$l->[3], 'name'=>$l->[4], 'nname'=>$l->[5], 'monitor'=>$l->[6], 'type'=>$l->[7], 'id_cfg_notification'=>$l->[0], 'timeout'=>$l->[11], 'severity'=>$l->[12], 'wsize'=>$l->[13], 'template'=>$l->[14], 'title_template'=>$l->[15], 'calendar'=>'', 'app'=>1 };
		}
   }

	return \%data;

}

#----------------------------------------------------------------------------
# Funcion: get_cfg_watch_multi_severity
# Obtiene los monitores definidos con varias severidades
#----------------------------------------------------------------------------
sub get_cfg_watch_multi_severity {
my ($self,$dbh)=@_;

   if (! defined $dbh) { return undef; }

   my %data=();
   my $rres=sqlSelectAll($dbh, 'c.monitor, c.type_mwatch, a.expr, a.severity', 'cfg_notifications c, alert_type a', 'c.monitor=a.monitor' );

   foreach my $l (@$rres) { 
		#| s_esp_cpu_avg_mibhost-174e4020 | 0 | v1>85:v1>75: | 1 |
		if ($l->[2]!~/\:/) { next; }
		$data{$l->[0]} = { 'type_mwatch' => $l->[1], 'expr'=>$l->[2] };
	}

	return \%data;

}

#----------------------------------------------------------------------------
# Funcion: get_alerts_by_cid
# Descripcion:
# a.id_device,a.id_alert_type,t.cause,d.name,d.domain,d.ip
#----------------------------------------------------------------------------
sub get_alerts_by_cid {
my ($self,$dbh,$cid)=@_;

   if (! defined $dbh) { return undef; }

   my $rres=sqlSelectAll($dbh,
                        'id_device,id_alert_type,cause,name,domain,ip,notif,id_alert,mname,watch,event_data,ack,id_ticket,severity,type,date,counter,id_metric',
                        'alerts',
                        "counter>0 and cid=\'$cid\'");

   $self->error($libSQL::err);
   $self->errorstr($libSQL::errstr);
   $self->lastcmd($libSQL::cmd);

   if ($libSQL::err) {
      #$self->log('warning',"get_alerts_by_id::[ERROR] (EDB=$libSQL::err) $libSQL::errstr ($libSQL::cmd)");
		$self->manage_db_error($dbh,"get_alerts_by_id");
   }

   return $rres;

}

#----------------------------------------------------------------------------
# Funcion: get_views_by_cid
# Descripcion:
# a.id_device,a.id_alert_type,t.cause,d.name,d.domain,d.ip
#----------------------------------------------------------------------------
sub get_views_by_cid {
my ($self,$dbh,$cid)=@_;

   if (! defined $dbh) { return undef; }

   my $rres=sqlSelectAll($dbh,
                        'id_cfg_view,name,type,function,weight,background,red,orange,yellow,itil_type,blue,ruled,severity,cid',
                        'cfg_views',
                        "cid=\'$cid\'");

   $self->error($libSQL::err);
   $self->errorstr($libSQL::errstr);
   $self->lastcmd($libSQL::cmd);

   if ($libSQL::err) {
      #$self->log('warning',"get_views_by_id::[ERROR] (EDB=$libSQL::err) $libSQL::errstr ($libSQL::cmd)");
		$self->manage_db_error($dbh,"get_views_by_id");
   }

   $self->log('warning',"get_views_by_id::[ERROR] (EDB=$libSQL::err) $libSQL::errstr ($libSQL::cmd)");
   return $rres;

}


#----------------------------------------------------------------------------
# Funcion: get_alerts
# Descripcion:
# a.id_device,a.id_alert_type,t.cause,d.name,d.domain,d.ip
#----------------------------------------------------------------------------
sub get_alerts {
my ($self,$dbh)=@_;

   if (! defined $dbh) { return undef; }

#   my $rres=sqlSelectAll($dbh,
#                        'a.id_device,a.id_alert_type,t.cause,d.name,d.domain,d.ip,a.notif,a.id_alert,a.mname',
#                        'alerts a, alert_type t, devices d',
#                        "a.ack=0 and a.counter>0 and a.id_alert_type=t.id_alert_type and a.id_device=d.id_dev");

	#Alertas originadas port monitores (watches)
   my $rres=sqlSelectAll($dbh,
								'a.id_device,a.id_alert_type,t.cause,d.name,d.domain,d.ip,a.notif,a.id_alert,a.mname,a.watch,a.event_data',
								'alerts a, alert_type t, devices d, metrics m',
								#'a.ack=0 and a.counter>0 and a.id_device=d.id_dev and a.id_device=m.id_dev and a.mname=m.name and m.watch=t.monitor');
								'a.counter>0 and a.id_device=d.id_dev and a.id_device=m.id_dev and a.mname=m.name and m.watch=t.monitor');

   $self->error($libSQL::err);
   $self->errorstr($libSQL::errstr);
   $self->lastcmd($libSQL::cmd);

   if ($libSQL::err) {
      #$self->log('warning',"get_alerts::[ERROR] (EDB=$libSQL::err) $libSQL::errstr ($libSQL::cmd)");
		$self->manage_db_error($dbh,"get_alerts");
   }



	#Alertas producidas por metricas tcp/ip configuradas
   my $rres1=sqlSelectAll($dbh,
								'a.id_device,a.id_alert_type,t.description,d.name,d.domain,d.ip,a.notif,a.id_alert,a.mname,a.watch,a.event_data',
								'alerts a,cfg_monitor t, devices d',
								#'a.ack=0 and a.counter>0 and a.mname=t.monitor and a.id_device=d.id_dev');
								'a.counter>0 and a.mname=t.monitor and a.id_device=d.id_dev');


   $self->error($libSQL::err);
   $self->errorstr($libSQL::errstr);
   $self->lastcmd($libSQL::cmd);

   if ($libSQL::err) {
      #$self->log('warning',"get_alerts::[ERROR] (EDB=$libSQL::err) $libSQL::errstr ($libSQL::cmd)");
		$self->manage_db_error($dbh,"get_alerts");
   }


   #Alertas producidas por alertas remotas / traps
   my $rres2=sqlSelectAll($dbh,
                        'a.id_device,a.id_alert_type,t.descr,d.name,d.domain,d.ip,a.notif,a.id_alert,a.mname,a.watch,a.event_data',
                        'alerts a,cfg_remote_alerts t, devices d',
                        #'a.ack=0 and a.counter>0 and a.mname=t.subtype and a.id_device=d.id_dev and t.subtype not in ("mon_snmp", "mon_xagent", "mon_wbem")');
                        'a.counter>0 and a.mname=t.subtype and a.id_device=d.id_dev and t.subtype not in ("mon_snmp", "mon_xagent", "mon_wbem")');

   $self->error($libSQL::err);
   $self->errorstr($libSQL::errstr);
   $self->lastcmd($libSQL::cmd);

   if ($libSQL::err) {
      #$self->log('warning',"get_alerts::[ERROR] (EDB=$libSQL::err) $libSQL::errstr ($libSQL::cmd)");
		$self->manage_db_error($dbh,"get_alerts");
   }


	push @$rres, @$rres1;
	push @$rres, @$rres2;
   return $rres;

}


#----------------------------------------------------------------------------
# Funcion: get_alerts_by_monitor
# Descripcion:
# a.id_device,a.id_alert_type,t.cause,d.name,d.domain,d.ip
#----------------------------------------------------------------------------
sub get_alerts_by_monitor {
my ($self,$dbh)=@_;

   if (! defined $dbh) { return undef; }

   my $rres=sqlSelectAll($dbh,
								'a.id_device,a.id_alert_type,t.cause,d.name,d.domain,d.ip,a.notif,a.id_alert',
                        'alerts a, alert_type t, devices d',
                        "a.ack=0 and a.counter>0 and a.id_alert_type=t.id_alert_type and a.id_device=d.id_dev");
   return $rres;
}


#----------------------------------------------------------------------------
# Funcion: get_alerts_by_latency
# Descripcion:
# a.id_device,a.id_alert_type,t.cause,d.name,d.domain,d.ip
#----------------------------------------------------------------------------
sub get_alerts_by_latency {
my ($self,$dbh)=@_;

   if (! defined $dbh) { return undef; }

   my $rres=sqlSelectAll($dbh,
								'a.id_device,a.id_alert_type,t.description,d.name,d.domain,d.ip,a.notif,a.id_alert',
                        'alerts a, cfg_monitor t, devices d',
                        "a.ack=0 and a.counter>0 and a.mname=t.monitor and a.id_device=d.id_dev");
   return $rres;
}



#----------------------------------------------------------------------------
# Funcion: get_alerts_pre
# Descripcion:
# d.name,d.domain,d.ip,t.monitor,t.expr,t.params,a.mname
#----------------------------------------------------------------------------
sub get_alerts_pre {
my ($self,$dbh)=@_;

   if (! defined $dbh) { return undef; }

   my $rres=sqlSelectAll($dbh,
                        'd.name,d.domain,d.ip,t.monitor,t.expr,t.params,a.mname,t.severity,d.status',
                        'alerts a, alert_type t, devices d',
                        "a.id_alert_type=t.id_alert_type and a.id_device=d.id_dev");

   return $rres;
}


#----------------------------------------------------------------------------
# Funcion: get_crawler_lapses
# Descripcion:
# @=(300,3600...)
#----------------------------------------------------------------------------
sub get_crawler_lapses {
my ($self,$dbh)=@_;
my @rv=();
my $rs;
my $retries=5;

	do {

      if (! defined $dbh) {
         $self->log('warning',"get_crawler_lapses::[WARN] DBH = UNDEF");
         $dbh=$self->open_db();
      }

      if ($libSQL::err) {
         $self->log('warning',"get_crawler_lapses::[WARN] (EDB=$libSQL::err) $libSQL::errstr ($libSQL::cmd) (R=$retries)");
         $retries -=1;
         $self->close_db($dbh);
         $dbh=$self->open_db();
      }

  		$rs=sqlSelectAll($dbh,'distinct lapse',$TAB_METRICS_NAME,'','order by lapse');

	} while ( ($libSQL::err) && ($retries) );

   $self->error($libSQL::err);
   $self->errorstr($libSQL::errstr);
   $self->lastcmd($libSQL::cmd);

   if ($libSQL::err) {
      #$self->log('warning',"get_crawler_lapses::[ERROR] Superados reintentos (R=$retries) (EDB=$libSQL::err) $libSQL::errstr ($libSQL::cmd)");
		$self->manage_db_error($dbh,"get_crawler_lapses");
   }
	else {
		foreach my $l (@$rs){
			foreach my $v (@$l) { push @rv,$v; }	
		}
	}

   return \@rv;
}


#----------------------------------------------------------------------------
# Funcion: get_crawler_types
# Descripcion:
# @=(routers,hosts...)
#----------------------------------------------------------------------------
sub get_crawler_types {
my ($self,$dbh)=@_;
#my @rv=();

   my $rs=sqlSelectAll($dbh,'distinct type, count(*)',$TAB_DEVICES_NAME,'status = 0 group by type order by type');
   #foreach my $l (@$rs){
   #   foreach my $v (@$l) { push @rv,$v; }
   #}
   #return \@rv;
   return $rs;
}



#----------------------------------------------------------------------------
# Funcion: get_service_id
# Descripcion:
#----------------------------------------------------------------------------
sub get_service_id {
my ($self,$dbh,$data)=@_;
my %table=();
my $rv=undef;

   if (defined $data->{name}) {$table{name}= lc $data->{name};}
	else { return undef; }

   my $rres=sqlSelectAll($dbh,'id_serv',$TAB_SERVICES_NAME,"name=\'$table{name}\'");
   return $rres->[0][0];
}





#----------------------------------------------------------------------------
# Funcion: get_device_id
# Descripcion:
#----------------------------------------------------------------------------
sub get_device_id {
my ($self,$dbh,$data)=@_;
my %table=();
my $rv=undef;
my $condition='';

   if (defined $data->{name}) {
		$table{name}= lc $data->{name};
		if (defined $data->{domain}) {
			$table{domain}= lc $data->{domain};
			$condition="name=\'$table{name}\' and domain=\'$table{domain}\'";
		}
		else {$condition="name=\'$table{name}\'"; }
	}
	elsif (defined $data->{ip}) {
		$table{ip}= $data->{ip};
		$condition="ip=\'$table{ip}\'";
	}
   else { return undef; }

   my $rres=sqlSelectAll($dbh,'id_dev',$TAB_DEVICES_NAME,$condition);
   return $rres->[0][0];
}


#----------------------------------------------------------------------------
# Funcion: get_ip2name_vector
# Descripcion:
#----------------------------------------------------------------------------
sub get_ip2name_vector {
my ($self,$dbh)=@_;

   my %data=();
   my $sql="SELECT ip,name,domain,status,id_dev,critic FROM devices";
   my $rres=sqlSelectAllCmd($dbh,$sql,'ip');
   return $rres;
#   foreach my $d (@$rres) {
   #
   #   my $ip=$d->[0];
   #   my $name=$d->[1];
   #   my $domain=$d->[2];
   #   $data{$ip}=$name;
   #   if ($domain) { $data{$ip}=$name.'.'.$domain; }
   #}
   #return \%data;
}


#----------------------------------------------------------------------------
# Funcion: get_alert_type_id
# Descripcion:
#----------------------------------------------------------------------------
sub get_alert_type_id {
my ($self,$dbh,$data)=@_;
my %table=();
my $rv=undef;
my $condition='';

   if (! defined $data->{cause}) { return undef; }
	else {
		$condition="cause=\'$data->{cause}\'";
   	my $rres=sqlSelectAll($dbh,'id_alert_type',$TAB_ALERT_TYPE_NAME,$condition);
   	return $rres->[0][0];
	}
}

#----------------------------------------------------------------------------
# Funcion: get_alert_type_info
# Descripcion:
#----------------------------------------------------------------------------
sub get_alert_type_info {
my ($self,$dbh,$data)=@_;
my %table=();
my $rv=undef;
my $condition='';

   if (! defined $data->{monitor}) { return undef; }
   else {
      $condition="monitor in (\'$data->{monitor}\')";
      my $rres=sqlSelectAll($dbh,'cause,severity,expr,wsize',$TAB_ALERT_TYPE_NAME,$condition);
      return $rres;
   }
}


#----------------------------------------------------------------------------
# Funcion: get_monitor
# Descripcion:
#----------------------------------------------------------------------------
sub get_monitor {
my ($self,$dbh,$data)=@_;
my %table=();
my $rv=undef;
my $condition='';

   if (! defined $data->{monitor}) { return undef; }
   else {
      $condition="monitor in (\'$data->{monitor}\')";
      my $rres=sqlSelectAll($dbh,'cause,severity,expr',$TAB_ALERT_TYPE_NAME,$condition);
      return $rres;
   }
}


#----------------------------------------------------------------------------
# Funcion: get_latency_metric_info
# Descripcion:
#----------------------------------------------------------------------------
sub get_latency_metric_info {
my ($self,$dbh,$data)=@_;
my %table=();
my $rv=undef;
my $condition='';

   if (! defined $data->{monitor}) { return undef; }
   else {
      $condition="monitor in (\'$data->{monitor}\')";
      my $rres=sqlSelectAll($dbh,'description,severity,params',$TAB_CFG_MONITOR,$condition);
      return $rres;
   }
}



#----------------------------------------------------------------------------
# Funcion: get_notification_type_id
# Descripcion:
#----------------------------------------------------------------------------
sub get_notification_type_id {
my ($self,$dbh,$data)=@_;
my %table=();
my $rv=undef;
my $condition='';

   if (! defined $data->{notif}) { return undef; }
   else {
      $condition="name=\'$data->{notif}\'";
      my $rres=sqlSelectAll($dbh,'id_notification_type',$TAB_NOTIFICATION_TYPE_NAME,$condition);
      return $rres->[0][0];
   }
}

#----------------------------------------------------------------------------
# Funcion: get_assigned_metrics
# Descripcion:
#----------------------------------------------------------------------------
sub get_assigned_metrics {
my ($self,$dbh,$watches,$data)=@_;
my %table=();
my $rv=undef;
my @c=();
my ($company,$item);
my @result=();

#select c.lapse,c.type,c.subtype,c.monitor,a.expr,a.params,c.active_iids from cfg_assigned_metrics c left join alert_type a on a.monitor=c.monitor where c.range='*' or c.range='192.168.4.152' or c.range='sliromai2.cm.es' or c.range='hosts.servicios-red.pop3.linux';

	push @c, 'myrange=\'*\'';
   if ($data->{oid}) {
		
		if ( ($data->{oid} =~ /(\.1\.3\.6\.1\.4\.1\.\d+)(.*)/) ||
			  ($data->{oid} =~ /(enterprises\.\d+)(.*)/) ) {
			$company=$1;
			$item=$2;
			push @c, "myrange=\'$company\'";
			push @c, "myrange=\'$data->{oid}\'";
		}
   }

	if ($data->{ip}) { push @c, "myrange=\'$data->{ip}\'"; }
	if ($data->{name}) { push @c, "myrange=\'$data->{name}\'"; }
	if ($data->{type}) { push @c, "myrange=\'$data->{type}\'"; }

	my $condition = join (' or ',@c);
	if (! $condition) { return undef; }

#print "****FML*******>>>>$condition\n";

   #Obtengo monitores ---------------------------------------------
	# select c.lapse,c.type,c.subtype,c.monitor,a.params,a.expr,c.active_iids from cfg_assigned_metrics c  left join alert_type a on a.monitor=c.monitor where c.monitor like 's_%' and (c.range='*' or c.range='10.1.254.204');
   my $values='c.monitor,a.expr,c.active_iids,a.cause,a.severity';
   my $tables="$TAB_CFG_ASSIGNED_METRICS_NAME c left join $TAB_ALERT_TYPE_NAME a on a.monitor=c.monitor";

   my $rmon=sqlSelectAll($dbh,$values,$tables,"($condition)");

   #Obtengo metricas ----------------------------------------------
	#select c.lapse,c.type,c.subtype,c.monitor,a.params,c.active_iids,c.id_type from cfg_assigned_metrics c  left join cfg_monitor a on a.monitor=c.subtype where (c.range='*' or c.range='10.1.254.204');

   #my $values='c.lapse,c.type,c.subtype,c.monitor,a.expr,a.params,c.active_iids,a.cause,c.id_type';
   #my $tables="$TAB_CFG_ASSIGNED_METRICS_NAME c left join $TAB_ALERT_TYPE_NAME a on a.monitor=c.monitor";
   #$values='c.lapse,c.type,c.subtype,c.monitor,a.params,c.active_iids,a.description as cause,c.id_type';
   $values='c.lapse,c.type,c.subtype,c.monitor,a.params,c.active_iids,c.id_type,a.description,a.severity';
   $tables="$TAB_CFG_ASSIGNED_METRICS_NAME c left join $TAB_CFG_MONITOR a on a.monitor=c.subtype";
	
   my $rres=sqlSelectAll($dbh,$values,$tables,"($condition)");

	# -------------------------------------------------------------------------------------------------
	# Contemplo el caso de que existan diferentes asignaciones de una metrica concreta al dispositivo
	# porque cumpla diferentes criterios (*, ip, tipo ...)
	my %expanded=();
   foreach my $m (@$rres) {
	
		#c.lapse,c.type,c.subtype,c.monitor,a.expr,a.params,c.active_iids
      my $lapse=$m->[0];
      my $type=$m->[1];
      my $subtype=$m->[2];
      my $monitor=$m->[3] || '';
      my $params=$m->[4] || '';
      my $active_iids=$m->[5];
      #my $cause=$m->[6];
      my $id_type=$m->[6];
		my $expr='';
		my $cause=$m->[7];
      my $severity=$m->[8];

#print " *FML* $lapse,$type,$subtype,$expr,$params,$cause \n";

      # Existen diferentes situaciones que hay que manejar:
		# OJO ESTE CASO YA NO ES POSIBLE
      # Si hay varias asignaciones identicas decido dejo la mas restrictiva ----------------------
      #|   300 | snmp    | traffic_mibii_if | NULL    | NULL | NULL   | 1,2,9,14,16 |
      #|   300 | snmp    | traffic_mibii_if | NULL    | NULL | NULL   | all         |

      # Tambien pueden existir asignaciones con y sin monitor:
		# NO SE ADMITE EL VALOR 'all' en tabla
      #| 99 | 10.1.254.69 | 0 | 1 | 300 | snmp  | disk_mibhost  | NULL                | 1,2,3,4     |
      #|100 | 10.1.254.69 | 1 | 1 | 300 | snmp  | disk_mibhost  | s_disk_mibhost_2022 | 1           |

      #| 99 | 10.1.254.69 | 0 | 1 | 300 | snmp  | disk_mibhost  | NULL                | 1,2,3,4,5,6 |
      #|100 | 10.1.254.69 | 1 | 1 | 300 | snmp  | disk_mibhost  | s_disk_mibhost_2022 | 1           |

#----------------------------

		# Si existe monitor busco los datos (expr, active_iids) del mismo
		if ($monitor =~ /^s_/) {
		#if ($id_type) {
			foreach my $mon (@$rmon) {
				#c.monitor,a.expr,c.active_iids,a.cause				
				if (($monitor) && ($mon->[0] eq $monitor)) { $expr=$mon->[1]; $active_iids=$mon->[2]; $cause=$mon->[3]; ; $severity=$mon->[4]; }
			}
		}

#print " *FML* $lapse,$type,$subtype,$expr,$params,$cause,$severity \n";

		# Para evitar los warnings del join si hay valores no definidos:
		#my $new_key=join(',',$lapse,$type,$subtype,$expr,$params,$cause,$severity);
		my $new_key="$lapse,$type,$subtype,";
		if ($expr) { $new_key .= $expr; }
		$new_key .= ',';
		if ($params) { $new_key .= $params; }
		$new_key .= ',';
		if ($cause) { $new_key .= $cause; }
		$new_key .= ',';
		if ($severity) { $new_key .= $severity; }
		$new_key .= ',';
		#----------------------------------------------------------------------			

		$expanded{$subtype}={ lapse=>$lapse, type=>$type, subtype=>$subtype, expr=>$expr, params=>$params, cause=>$cause, severity=>$severity };
		my @ii=split( ',', $active_iids );
		foreach my $i (@ii) {
			#if ($id_type) { $watches->{$subtype}->{$i}=$monitor;  }
			if ($monitor =~ /^s_/) { $watches->{$subtype}->{$i}=$monitor;  }
			else { $watches->{$subtype}->{$i}=0; }
		}
   }

	foreach my $s (sort keys %expanded) {
		push @result, $expanded{$s};
	}


#   while ( my ($k,$v) = each %expanded) {
#print "**EXPANDED1***>>> $k :: $v\n";
#      my ($lapse,$type,$subtype,$expr,$params,$cause)=split (',', $k);
#      my %m=();
#      #while ( my ($k1,$v1) = each %$v ) {
#      foreach  my $k1 ( sort {$a <=> $b} keys %$v ) {
#         my $v1=$v->{$k1};
#print "  **EXPANDED2***>>> $k1 ::: $v1\n";
#         if (! $m{$v1}) { $m{$v1} = $k1; }
#         else { $m{$v1} .= ",$k1"; }
#      }
#      while ( my ($mm,$ii)=each %m ) {
#print "    **EXPANDED3*$subtype $ii ***>>> $mm\n";
#         push @result, { lapse=>$lapse, type=>$type, subtype=>$subtype, monitor=>$mm, expr=>$expr, params=>$params, active_iids=>$ii, cause=>$cause };
#      }
#   }


   return \@result;
}


#----------------------------------------------------------------------------
# Funcion: get_template_metrics_counter
# Descripcion:
# Obtiene el numero de metricas que existen en la tabla prov_template_metrics
# asociadas al dispositivo $id_dev
#----------------------------------------------------------------------------
sub get_template_metrics_counter {
my ($self,$dbh,$id_dev)=@_;

	my $n=sqlSelectAll($dbh,'count(*)','prov_template_metrics2iid',"id_dev=$id_dev");
   $self->error($libSQL::err);
   $self->errorstr($libSQL::errstr);
   $self->lastcmd($libSQL::cmd);

	return $n->[0][0];

}


#----------------------------------------------------------------------------
# Funcion: get_default_metrics2device
# Descripcion:
# Rellena el vector @ProvisionLite::default_metrics a partir de las metricas
# provisionadas para el dispositivo.
#----------------------------------------------------------------------------
sub get_default_metrics2device {
my ($self,$dbh,$id_dev)=@_;
my ($company,$item);

   #@ProvisionLite::default_metrics=();
   my $values='include,lapse,type,subtype';
   my $table='prov_default_metrics2device';
   my $rres=sqlSelectAll($dbh,$values,$table,"id_dev=$id_dev");
   $self->error($libSQL::err);
   $self->errorstr($libSQL::errstr);
   $self->lastcmd($libSQL::cmd);


   foreach my $m (@$rres) {

      push @ProvisionLite::default_metrics, {'include'=>$m->[0], 'lapse'=>$m->[1],  'type' => $m->[2], 'subtype' => $m->[3] };
   }

   return 1;

}



#----------------------------------------------------------------------------
# Funcion: apply_rules_to_template_metrics
# Descripcion:
#
# action: 0->deny 1->allow
#| id_rules_template | mtype   | subtype          | pattern        | action | watch | mode |
#+-------------------+---------+------------------+----------------+--------+-------+------+
#|                 1 | snmp    | traffic_mibii_if | VoiceEncapPeer |      0 | 0     |    0 |
#
#      my $r1=$STORE->get_from_db($dbh,'mtype,subtype,pattern,action,watch,mode','prov_default_rules_templates',"id_rules_template=1");
#      if (scalar @$r1) {
#         foreach my $r (@$r1) {
#            push @ProvisionLite::metric_rules,$r;
#         }
#      }
#
#----------------------------------------------------------------------------
sub apply_rules_to_template_metrics {
my ($self,$dbh,$id_dev,$rules)=@_;

#select lapse,type,subtype,id_tm2iid,b.id_template_metric,b.id_dev,hiid,label,status from prov_template_metrics a, prov_template_metrics2iid b where a.id_template_metric=b.id_template_metric and a.id_dev=6154 limit 5


   my @result=();
   my $values='type,subtype,id_tm2iid,b.id_template_metric,hiid,label,status';
   my $tables="prov_template_metrics a, prov_template_metrics2iid b";
   my $where="a.id_template_metric=b.id_template_metric and a.id_dev=$id_dev";

   my $rres=sqlSelectAll($dbh,$values,$tables,$where);

	my %table=();
   foreach my $m (@$rres) {

		# type,subtype,id_tm2iid,b.id_template_metric,hiid,label,status
		# 0     1       2          3                   4    5     6
		my $label=$m->[6];
		$table{'id_template_metric'}=$m->[3];
		$table{'id_dev'}=$id_dev;
		$table{'hiid'}=$m->[4];
		$table{'status'}=$m->[6];

		my $type=$m->[0];
		my $subtype=$m->[1];

		foreach my $r (@$rules) {

			#field="label" pattern="VoiceEncapPeer" mode="match" action="deny"
			# Por ahora solo se comtempla el label

			#mtype,subtype,pattern,action,watch,mode
			my ($rule_type, $rule_subtype, $rule_pattern, $rule_action, $rule_watch, $rule_mode)=($r->[0], $r->[1], $r->[2], $r->[3], $r->[4], $r->[5]);

			# Si no es una regla para el tipo/subtipo de la metrica salto a la siguiente regla porque
			# esta no aplica.
			if (($type ne $rule_type) || ($subtype ne $rule_subtype)) { next; }

			if ( $label =~ /$rule_pattern/) {
				if ($rule_action == 0 ) { $table{'status'}=1;  }
				else { $table{'status'}=0; }
				$self->log('debug',"apply_rules_to_template_metrics::[DEBUG] MATCH $rule_pattern en $label ACTION=$rule_action (ID_DEV=$id_dev)");
				last;
			}
		}


		# Actualizo entrada en "prov_template_metrics2iid"
      my $rv=sqlUpdate($dbh,'prov_template_metrics2iid',\%table,"id_template_metric = $table{'id_template_metric'} && hiid=\'$table{hiid}\'");
      $self->error($libSQL::err);
      $self->errorstr($libSQL::errstr);
      $self->lastcmd($libSQL::cmd);

      if ($libSQL::err != 0) {
         $self->log('warning',"apply_rules_to_template_metrics::[WARN] Error en Insert/Update template_metric $table{hiid}.$table{id_template_metric} (RV=undef) RES=$libSQL::err ($libSQL::errstr) SQL=$libSQL::cmd");
      }
   }

}


#----------------------------------------------------------------------------
# Funcion: set_template_metrics_by_custom_file
# Descripcion:
# Si el dispositivo tiene un fichero de metricas para la plantilla, se aplica.
# Si no tiene fichero definido, no hace nada.
# El nombre del fichero se especifica en el campo de dispositivo CNM-METRICS
# La ruta es /store/www-user/automation (Se sube desde configuracion)
#----------------------------------------------------------------------------
sub set_template_metrics_by_custom_file {
my ($self,$dbh,$id_dev)=@_;

   my $custom_field = 'CNM-METRICS';
   my $file_path = '/store/www-user/automation';
   my $rres = $self->get_from_db_cmd($dbh,"SELECT id FROM devices_custom_types WHERE descr = '$custom_field'");

   # Si no esta definido el custom_field termina.
   if (!defined $rres->[0][0]) { return; }

   my $field = 'columna'.$rres->[0][0];
   #select columna3 from devices_custom_data where id_dev=431;
   $rres = $self->get_from_db_cmd($dbh,"SELECT $field FROM devices_custom_data WHERE id_dev=$id_dev");

   my $file_metrics = join ('/', $file_path, $rres->[0][0]);
   if (! -f $file_metrics) {
		$self->log('warning',"set_template_metrics_by_custom_file::[WARN] NO EXISTE file_metrics=$file_metrics");
      return;
   }

	my $rules={};
   my $x=$self->slurp_file($file_metrics);
   my $json = JSON->new();
   $json = $json->canonical([1]);
	
	eval {
   	$rules = $json->decode($x);
 	};
 	if ($@) { $self->log('error',"set_template_metrics_by_custom_file::ERROR AL DECODIFICAR $file_metrics ($@)"); }

	print Dumper($rules);

#          'enable' => [
#                        {
#                          'label_like' => 'ICMP',
#                          'type' => 'latency',
#                          'watch' => '',
#                          'subtype' => 'disp_icmp'
#                        },
#                        {
#                          'watch' => '',
#                          'subtype' => 'status_mibii_if',
#                          'type' => 'snmp',
#                          'label_like' => 'Tunnel0'
#                        },


	my ($enable, $disable) = ([], []);
	if (exists $rules->{'enable'}) { $enable = $rules->{'enable'}; }
	if (exists $rules->{'disable'}) { $disable = $rules->{'disable'}; }

	#--------------------------------------------
   my @result=();
   my $values='c.id_template_metric,c.type,c.subtype,i.watch,i.iid,i.mname,i.label,i.status,c.lapse';
   my $tables="prov_template_metrics c, prov_template_metrics2iid i";
   my $where="c.id_template_metric=i.id_template_metric and c.id_dev=$id_dev";
   $rres=sqlSelectAll($dbh,$values,$tables,$where);

	my @template=();
   foreach my $m (@$rres) {

		my ($id_template_metric,$type,$subtype,$watch,$iid,$mname,$label,$status,$lapse) = ($m->[0],$m->[1],$m->[2],$m->[3],$m->[4],$m->[5],$m->[6],$m->[7],$m->[8]);
		my $rule_status = 1;
		foreach my $r (@$enable) {
			my $label_like = $r->{'label_like'};
			#$self->log('debug',"set_template_metrics_by_custom_file::**DEPURA** label_like=$label_like >> label=$label");
			if ( ($subtype eq $r->{'subtype'}) && ($type eq $r->{'type'}) && ($label=~/$label_like/)) { 
				$rule_status = 0;
				last;
			}
		}

		$self->log('debug',"set_template_metrics_by_custom_file::id=$id_template_metric status=$status ($rule_status) label=$label");

		my %table = ('watch'=>$watch, 'status'=>$rule_status);
		my $condition="id_template_metric=$id_template_metric AND mname='$mname'";
	   my $rv=sqlUpdate($dbh,'prov_template_metrics2iid',\%table,$condition);

   	$self->error($libSQL::err);
   	$self->errorstr($libSQL::errstr);
   	$self->lastcmd($libSQL::cmd);
   	if ($libSQL::err) {
      	$self->manage_db_error($dbh,"set_template_metrics_by_custom_file");
   	}

   }
}

#----------------------------------------------------------------------------
# Funcion: get_template_metrics
# Descripcion:
# Es un update de get_cfg_assigned_metrics. Se modifica el modelo de datos
# y la otra rutina queda obsoleta.
#----------------------------------------------------------------------------
sub get_template_metrics {
my ($self,$dbh,$id_dev)=@_;


	my @result=();
   my $values='c.type,c.subtype,i.watch,i.iid,i.mname,i.label,i.status,c.lapse';
   my $tables="prov_template_metrics c, prov_template_metrics2iid i";
	#my $where="c.id_template_metric=i.id_template_metric and c.id_dev=$id_dev and i.status=0";
	my $where="c.id_template_metric=i.id_template_metric and c.id_dev=$id_dev";

	my $rres=sqlSelectAll($dbh,$values,$tables,$where);

	#snmp,disk_mibhost,0,1,disk_mibhost-1,"Disco x ...",1
	#latency,w_mon_tcp-xxxx,0,'none',w_mon_tcp-xxxx,"Puerto x ...",1

	my %DATA_BASE=();
	my %DATA_IIDS=();
   foreach my $m (@$rres) {

		#c.type,c.subtype,c.watch,i.iid,i.mname,i.label,i.status
#      my $type=$m->[0];
#      my $subtype=$m->[1];
#      my $watch=$m->[2];
#      my $iid=$m->[3];
#      my $mname=$m->[4];
#      my $label=$m->[5];
#      my $severity=$m->[6];

		#push @result, { 'type' => $m->[0], 'subtype' => $m->[1], 'watch' => $m->[2], 'iid' => $m->[3], 'mname' => $m->[4], 'label' => $m->[5], 'status' => $m->[6], 'lapse' => $m->[7] };
		my $subtype=$m->[1];
		if (! exists $DATA_BASE{$subtype}) {
			$DATA_BASE {$subtype} = { 'type' => $m->[0], 'subtype' => $m->[1], 'lapse' => $m->[7], 'include'=>1, 'IIDS'=>{}};
		}
		my $iid=$m->[3];
		$DATA_IIDS{$subtype}->{$iid} = { 'watch' => $m->[2], 'iid' => $m->[3], 'mname' => $m->[4], 'label' => $m->[5], 'status' => $m->[6]};


$self->log('debug',"get_template_metrics::METRICAS EN PLANTILLA DE id_dev=$id_dev SUBTYPE=$subtype IID=$iid ");

	}

#{'include'=>0/1, 'lapse'=>300/60...,  'type' =>snmp/latency..., 'subtype' => disk_mibhost... }
	foreach my $s (keys %DATA_BASE) {
		my %IIDS=();
		foreach my $i ( keys %{$DATA_IIDS{$s}} ) {
			$IIDS{$i}=$DATA_IIDS{$s}{$i};
		}
		push @result, { 'type' => $DATA_BASE{$s}->{'type'}, 'subtype' => $DATA_BASE{$s}->{'subtype'},'lapse' => $DATA_BASE{$s}->{'lapse'}, 'include'=>1, 'IIDS'=>\%IIDS };
	}
	return \@result;
}


#----------------------------------------------------------------------------
# Funcion: get_template_metrics_by_type
# Descripcion:
#----------------------------------------------------------------------------
sub get_template_metrics_by_type {
my ($self,$dbh,$id_dev,$type)=@_;


   my @result=();
   my $rres;

   if ($type eq 'snmp') {
      $rres=sqlSelectAll(  $dbh,
                        'c.type,c.subtype,i.watch,i.iid,i.mname,i.label,i.status,c.lapse,r.descr',
                        'prov_template_metrics c, prov_template_metrics2iid i, cfg_monitor_snmp r',
                        "c.id_template_metric=i.id_template_metric and c.subtype=r.subtype and c.type='snmp' and c.id_dev=$id_dev"
                     );
   }
   elsif ($type eq 'latency') {
      $rres=sqlSelectAll(  $dbh,
                        'c.type,c.subtype,i.watch,i.iid,i.mname,i.label,i.status,c.lapse,r.description',
                        'prov_template_metrics c, prov_template_metrics2iid i, cfg_monitor r',
                        "c.id_template_metric=i.id_template_metric and c.subtype=r.monitor and c.type='latency' and c.id_dev=$id_dev"
                     );
   }
   else {
		# Solose contemplan las que tienen iptab=1 que son las que se pueden asociar a dispositivo
		# Las otras necesitan configuración.
      $rres=sqlSelectAll(  $dbh,
                        'c.type,c.subtype,i.watch,i.iid,i.mname,i.label,i.status,c.lapse,r.description',
                        'prov_template_metrics c, prov_template_metrics2iid i, cfg_monitor_agent r',
                        "c.id_template_metric=i.id_template_metric and c.subtype=r.subtype and c.type!='snmp' and c.type!='latency' and c.id_dev=$id_dev and r.iptab=1"
                     );
   }



   #snmp,disk_mibhost,0,1,disk_mibhost-1,"Disco x ...",1,300,DESCR
   #latency,w_mon_tcp-xxxx,0,'none',w_mon_tcp-xxxx,"Puerto x ...",1,300 DESCR
#OJO es status deberia servir para fijar el valor del include fml !!!!!

   my %DATA_BASE=();
   my %DATA_IIDS=();
   foreach my $m (@$rres) {

      my $subtype=$m->[1];
      if (! exists $DATA_BASE{$subtype}) {
         $DATA_BASE {$subtype} = { 'type' => $m->[0], 'subtype' => $m->[1], 'lapse' => $m->[7], 'include'=>1, 'descr'=>$m->[8], 'IIDS'=>{}};
      }
      my $iid=$m->[3];
      $DATA_IIDS{$subtype}->{$iid} = { 'watch' => $m->[2], 'iid' => $m->[3], 'mname' => $m->[4], 'label' => $m->[5], 'status' => $m->[6]};


$self->log('debug',"get_template_metrics::METRICAS EN PLANTILLA DE id_dev=$id_dev SUBTYPE=$subtype IID=$iid ");

   }

#{'include'=>0/1, 'lapse'=>300/60...,  'type' =>snmp/latency..., 'subtype' => disk_mibhost... }
   foreach my $s (keys %DATA_BASE) {
      my %IIDS=();
      foreach my $i ( keys %{$DATA_IIDS{$s}} ) {
         $IIDS{$i}=$DATA_IIDS{$s}{$i};
      }
      push @result, { 'type' => $DATA_BASE{$s}->{'type'}, 'subtype' => $DATA_BASE{$s}->{'subtype'},'lapse' => $DATA_BASE{$s}->{'lapse'}, 'include'=>1, 'descr' => $DATA_BASE{$s}->{'descr'},  'IIDS'=>\%IIDS };
   }
   return \@result;
}


#----------------------------------------------------------------------------
# Funcion: store_template_metrics
# Descripcion:
# Almacena el template generado para el dispositivo
# Es un update de get_cfg_assigned_metrics. Se modifica el modelo de datos
# y la otra rutina queda obsoleta.
#----------------------------------------------------------------------------
sub store_template_metrics {
my ($self,$dbh,$id_dev,$data)=@_;


   my @result=();
   #------------------------------------------------------------
	foreach my $m (@$data) {

		my %table1=();
		my %table2=();
		$table1{'id_dev'}=$id_dev;
		$table1{'id_dest'}=$id_dev;
		$table1{'type'}=$m->{'type'};
		$table1{'subtype'}=$m->{'subtype'};
		if (exists $m->{'watch'}) {$table2{'watch'}=$m->{'watch'}; }
		#if (! $m->{'watch'}) {$table2{'watch'}=0; }
		#else { $table2{'watch'}=$m->{'watch'}; }



		$table1{'lapse'}=$m->{'lapse'};

		$table2{'iid'}=$m->{'iid'};

      my $hiid=md5_hex($table2{'iid'});
		$table2{'hiid'}=substr $hiid,0,20;

#FML REVISAR. En metricas especiales y custom el valor de iid es distinto.
#if ($table1{'subtype'} =~ /custom/) { $table2{'iid'}='ALL'; }

		$table2{'mname'}=$m->{'mname'};
		$table2{'label'}=$m->{'label'};
		$table2{'id_dev'}=$id_dev;
		$table2{'id_dest'}=$id_dev;

		$table2{'status'}= ($m->{'status'} eq '') ? 0 : $m->{'status'};

		#id_dev,lapse,type,subtype,watch. Se pone con noerr
  		my $rv=sqlInsert($dbh,'prov_template_metrics',\%table1,1);
  		$self->error($libSQL::err);
  		$self->errorstr($libSQL::errstr);
  		$self->lastcmd($libSQL::cmd);
#print "**FML** SQL=$libSQL::cmd\n";

  		my $id_template_metric=undef;
  		if ($libSQL::err==0) {
		
  			my $rres=sqlSelectAll($dbh,'id_template_metric','prov_template_metrics',"subtype = \'$table1{subtype}\' && id_dev=\'$id_dev\'");
  		   $id_template_metric=$rres->[0][0];
  		   $self->log('debug',"store_template_metrics::[DEBUG] Insert metric $table1{subtype}.$table1{id_dev} (ID=$id_template_metric)");
		}
		else {
		   $rv=sqlUpdate($dbh,'prov_template_metrics',\%table1,"subtype = \'$table1{subtype}\' && id_dev=\'$id_dev\'",1);
  			$self->error($libSQL::err);
  			$self->errorstr($libSQL::errstr);
	  	 	$self->lastcmd($libSQL::cmd);

#print "**FML** SQL=$libSQL::cmd\n";

   		if (defined $rv) {
      		my $rres=sqlSelectAll($dbh,'id_template_metric','prov_template_metrics',"subtype = \'$table1{subtype}\' && id_dev=\'$id_dev\'");
      		$id_template_metric=$rres->[0][0];
      		$self->log('debug',"store_template_metrics::[DEBUG] Update metric $table1{subtype}.$table1{id_dev} (ID=$id_template_metric)");
   		}
   		else {
      		$self->log('warning',"store_template_metrics::[WARN] Error en Insert/Update metric $table1{subtype}.$id_template_metric (RV=undef)");
   		}
   	}

		#id_template_metric,iid,label,status,mname
		$table2{'id_template_metric'}=$id_template_metric;

#print Dumper(\%table2);
#		# Ignoramos los errores porque lo habitual es tener clave duplicada al generar nuevamente
#		# las mismas metricas
#	   $rv=sqlInsert($dbh,'prov_template_metrics2iid',\%table2,1);
#      $self->error($libSQL::err);
#      $self->errorstr($libSQL::errstr);
#      $self->lastcmd($libSQL::cmd);
#
#print "**FMLSQL INSERT** $libSQL::cmd\n";
#      if ($libSQL::err != 0) {
#
#         $rv=sqlUpdate($dbh,'prov_template_metrics2iid',\%table2,"iid = \'$table2{iid}\' && id_template_metric=\'$id_template_metric\'");
#         $self->error($libSQL::err);
#         $self->errorstr($libSQL::errstr);
#         $self->lastcmd($libSQL::cmd);
#
#print "**FMLSQL UPDATE** $libSQL::cmd\n";
#			if ($libSQL::err != 0) {
#            $self->log('warning',"prov_template_metrics2iid::[WARN] Error en Insert/Update template_metric $table2{iid}.$table2{id_template_metric} (RV=undef)");
#         }
#      }
#
#
		# Sa hace un Insert or Update porque las instancias pueden cambiar
		$rv=sqlInsertUpdate4x($dbh,'prov_template_metrics2iid',\%table2,\%table2);
      $self->error($libSQL::err);
      $self->errorstr($libSQL::errstr);
      $self->lastcmd($libSQL::cmd);

      if ($libSQL::err != 0) {
         $self->log('warning',"prov_template_metrics2iid::[WARN] Error en Insert/Update template_metric $table2{iid}.$table2{id_template_metric} (RV=undef)");
      }




	}

}


#----------------------------------------------------------------------------
# Funcion: get_profiles_snmpv3
# Descripcion:
#----------------------------------------------------------------------------
sub get_profiles_snmpv3 {
my ($self,$dbh,$profiles)=@_;

	my $condition='';
	my $key_id=0;
	if ((ref($profiles) eq "ARRAY") && (scalar (@$profiles) > 0)) {

		# Profiles puede ser un vector de ids numericos (id_profile ) o de
		# cadenas de texto (profile_name). Chequeo el primer valor para ver
		# en que situacion estamos
		if ($profiles->[0] =~ /^\d+$/) {
			$condition = 'id_profile in ('. join(",", @$profiles). ')';
			$key_id=0; #indice del id_profile
		}
		else {
			my @escaped = map ("'$_'", @$profiles);
			$condition = 'profile_name in ('. join(",", @escaped). ')';
			$key_id=7; #indice del profile_name
		}
	}
	#           0,          1,       2,       3,          4,       5,          6,          7
	my $values='id_profile,sec_name,sec_level,auth_proto,auth_pass,priv_proto,priv_pass,profile_name';
   my $rres=sqlSelectAll($dbh,$values,'profiles_snmpv3',$condition);

   $self->error($libSQL::err);
   $self->errorstr($libSQL::errstr);
   $self->lastcmd($libSQL::cmd);

   if ($libSQL::err) {
      $self->manage_db_error($dbh,'get_profiles_snmpv3');
   }

	my %hprofiles=();
   foreach my $m (@$rres) {

		my $id_profile=$m->[$key_id];
		$hprofiles{$id_profile}= { 'sec_name'=>$m->[1], 'sec_level'=>$m->[2], 'auth_proto'=>$m->[3],
											'auth_pass'=>$m->[4], 'priv_proto'=>$m->[5], 'priv_pass'=>$m->[6] };
	}
   return \%hprofiles;
}


#----------------------------------------------------------------------------
# Funcion: get_proxy_list
# Descripcion:
#----------------------------------------------------------------------------
sub get_proxy_list {
my ($self,$dbh,$proxies)=@_;

   my $condition='';
   my $key_id=0;
   if ((ref($proxies) eq "ARRAY") && (scalar (@$proxies) > 0)) {

      # Proxies puede ser un vector de ids numericos (id_proxi ) o de
      # cadenas de texto (proxy_host). Chequeo el primer valor para ver
      # en que situacion estamos
      if ($proxies->[0] =~ /^\d+$/) {
         $condition = 'id_proxy in ('. join(",", @$proxies). ')';
         $key_id=0; #indice del id_profile
      }
      else {
         my @escaped = map ("'$_'", @$proxies);
         $condition = 'proxy_host in ('. join(",", @escaped). ')';
         $key_id=1; #indice del profile_name
      }
   }
   #           0,       1,         2,         3,          4,        5,        6,               7,              8,           9
   my $values='id_proxy,proxy_host,proxy_port,proxy_type,proxy_user,proxy_pwd,proxy_passphrase,proxy_key_path,proxy_options,proxy_exec_prefix';
   my $rres=sqlSelectAll($dbh,$values,'proxy_list',$condition);

   $self->error($libSQL::err);
   $self->errorstr($libSQL::errstr);
   $self->lastcmd($libSQL::cmd);

#$self->log('info',"get_proxy_list::[DEBUG] ****** (SQL=$libSQL::cmd)");

   if ($libSQL::err) {
      $self->manage_db_error($dbh,'get_proxy_list');
   }


   my %hproxies=();
   foreach my $m (@$rres) {

      my $id_proxy=$m->[$key_id];
      $hproxies{$id_proxy}= { 'proxy_host'=>$m->[1], 'proxy_port'=>$m->[2], 'proxy_type'=>$m->[3],
                              'proxy_user'=>$m->[4], 'proxy_pwd'=>$m->[5],
										'proxy_passphrase'=>$m->[6], 'proxy_key_path'=>$m->[7], 
										'proxy_options'=>$m->[8], 'proxy_exec_prefix'=>$m->[9] };
   }
   return \%hproxies;
}


#----------------------------------------------------------------------------
# Funcion: get_metric_id
# Descripcion:
#----------------------------------------------------------------------------
sub get_metric_id {
my ($self,$dbh,$data)=@_;
my %table=();
my $rv=undef;

   if (! defined $data->{name}) { return undef; }
	if (! defined $data->{id_dev}) { return undef; }

   my $rres=sqlSelectAll($dbh,'id_metric',$TAB_METRICS_NAME,"name=\'$data->{name}\' and id_dev=\'$data->{id_dev}\'");
   return $rres->[0][0];
}


#----------------------------------------------------------------------------
# Funcion: get_metrics_from_device
# Descripcion:
#----------------------------------------------------------------------------
sub get_metrics_from_device {
my ($self,$dbh,$data)=@_;
my %table=();
my $rv=undef;
my $condition='';
my $values='';
my $tables="$TAB_METRICS_NAME m, $TAB_DEVICES_NAME d";


	if (defined $data->{name}) {
		$condition="d.id_dev=m.id_dev and d.name=\'$data->{name}\'";
		if (defined $data->{domain}) { $condition .= " and d.domain=\'$data->{domain}\'"; }
	}
	elsif (defined $data->{ip}) { $condition="d.id_dev=m.id_dev and d.ip=\'$data->{ip}\'"; }
	elsif (defined $data->{id_dev}) { $condition="d.id_dev=m.id_dev and d.id_dev=\'$data->{id_dev}\'"; }
	else { return undef; }


	if (defined $data->{values}) { 	
		if ($data->{values} == 1) { $values='m.id_metric,m.mtype,m.status,m.label,m.file'; }
		elsif ($data->{values} == 2) { 	
			$values='m.id_metric,m.mtype,m.status,m.label,s.oid';
			$condition .= ' and m.id_metric = s.id_metric';
			$tables="$TAB_METRICS_NAME m, $TAB_DEVICES_NAME d, $TAB_METRIC2SNMP_NAME s";
		}
	}
	else { $values='m.id_metric,m.mtype,m.status,m.label,m.name'; }

   my $rres=sqlSelectAll($dbh,$values,$tables,"$condition order by m.name");
   return $rres;
}


#----------------------------------------------------------------------------
# Funcion: csv_alerts_store
# Descripcion:
#----------------------------------------------------------------------------
sub csv_alerts_store {
my ($self,$dbh,$outfile,$lapse)=@_;

#SELECT from_unixtime(a.date) as date ,a.mname,d.domain,d.name,d.ip,d.sysloc,d.id_dev,a.ack,a.duration,a.label as cause,a.severity,a.event_data, a.id_alert,a.id_alert_type,a.mname,a.id_ticket as ticket_type,a.type as tipo,a.watch FROM alerts_store a,devices d,cfg_devices2organizational_profile o, cfg_organizational_profile p WHERE d.id_dev=a.id_device AND d.id_dev=o.id_dev AND o.id_cfg_op=p.id_cfg_op and p.descr='Global' and a.date>(unix_timestamp(now()) - 86400);

	$lapse *= 86400;
   my $rres=sqlSelectAll($dbh,'from_unixtime(a.date) as date,a.mname,d.name,d.domain,d.ip,a.ack,a.duration,a.label as cause,a.severity,a.event_data,a.id_ticket as ticket_type,a.type as tipo,a.watch',
			'alerts_store a,devices d,cfg_devices2organizational_profile o, cfg_organizational_profile p',
			"d.id_dev=a.id_device AND d.id_dev=o.id_dev AND o.id_cfg_op=p.id_cfg_op and p.descr='Global' and a.date>(unix_timestamp(now()) - $lapse)",
			#"order by id_alert desc into outfile '$outfile' FIELDS TERMINATED BY ';'");
			"");
	
   $self->error($libSQL::err);
   $self->errorstr($libSQL::errstr);
   $self->lastcmd($libSQL::cmd);

   if ($libSQL::err) {
      #$self->log('warning',"csv_alerts_store::[ERROR] CSV=$outfile LAPSE=$lapse ($libSQL::err)");
		$self->manage_db_error($dbh,"csv_alerts_store CSV=$outfile LAPSE=$lapse");
   }
	else {
		$self->log('debug',"csv_alerts_store::[DEBUG] CSV=$outfile LAPSE=$lapse (SQL=$libSQL::cmd)");

		open (F,">$outfile");
		print F "FECHA;METRICA;NOMBRE;DOMINIO;IP;ACK;DURACION(segs);CAUSA;SEVERIDAD;EVENTO;TICKET;TIPO;MONITOR\n";
	   foreach my $m (@$rres) {

	      #date,mname,domain,name,ip,sysloc,id_dev,ack,duration,cause,severity,event_data,id_alert,id_alert_type,mname,ticket_type,tipo,watch
			$m->[9] =~ s/\n/ /g;
			print F join (';', @$m)."\n";
		}
		close F;
	}
}





#----------------------------------------------------------------------------
# Funcion: delete_metrics
# Descripcion:
#----------------------------------------------------------------------------
sub delete_metrics {
my ($self,$dbh,$data,$max)=@_;
my $condition='';

   if (defined $data->{'id_metric'}) { $condition="id_metric in ($data->{'id_metric'})"; }
   elsif (defined $data->{'id_dev'}) {
		$condition="id_dev in ($data->{'id_dev'})";
		if (defined $data->{'mname'}) { $condition .= " and name='".$data->{'mname'}."'"; }
		elsif (defined $data->{'subtype'}) { $condition .= " and subtype='".$data->{'subtype'}."'"; }
	}
   elsif (defined $data->{'status'}) { $condition="status = $data->{'status'}"; }
   else { return undef; }

	my $limit='';
	if ( $max=~/\d+/ ) { $limit="limit $max";}
   my $rres=sqlSelectAll($dbh,'id_metric','metrics',$condition,$limit);
	my @ids=();
	foreach my $r (@$rres) { push @ids, $r->[0]; }
	if (scalar @ids) {
		my $id_metric = join(',', @ids);
		$self->delete_metric_by_id($dbh,$id_metric);
	}
}


#----------------------------------------------------------------------------
# Funcion: delete_metric_by_id
# Descripcion:
#----------------------------------------------------------------------------
sub delete_metric_by_id {
my ($self,$dbh,$id_metric)=@_;
my ($rres,$condition)=([],'');

   if (defined $id_metric) { $condition="id_metric in ($id_metric)"; }
   else { return undef; }

	$self->log('debug',"delete_metric_by_id::[DEBUG] ID=$id_metric");
	# Elimina las relaciones con las vistas de la metrica en cuestion
	$rres=sqlDelete($dbh,'cfg_views2metrics',"id_metric in ($id_metric)");
   if ($libSQL::err) {
      $self->error($libSQL::err);
      $self->errorstr($libSQL::errstr);
      $self->lastcmd($libSQL::cmd);
      #$self->log('warning',"delete_metric_by_id::[ERROR] $libSQL::err = $libSQL::errstr ($libSQL::cmd)");
		$self->manage_db_error($dbh,"delete_metric_by_id");
      return undef;
   }

	# Elimina de otras tablas .......
   my $values='m.id_dev,m.name,m.type,m.subtype,d.ip,m.file';
   my $tables='metrics m, devices d';
   my $where="m.id_dev=d.id_dev and id_metric in ($id_metric)";
   $rres=sqlSelectAll($dbh,$values,$tables,$where);

   foreach my $m (@$rres) {
		
      my $id_dev=$m->[0];
      my $mname=$m->[1];
      my $type=$m->[2];
      my $subtype=$m->[3];
      my $ip=$m->[4];
      my $frrd='/opt/data/rrd/elements/'.$m->[5];

      #Elimina de alerts y alerts_store (Los datos del alerts_store ya no son consistentes)
      if ($id_dev && $mname) {
		   $rres=sqlDelete($dbh,'alerts',"id_device=$id_dev and mname='$mname'");
   		if ($libSQL::err) {
      		$self->error($libSQL::err);
	      	$self->errorstr($libSQL::errstr);
	   	   $self->lastcmd($libSQL::cmd);
   	   	#$self->log('warning',"delete_metric_by_id::[ERROR] $libSQL::err = $libSQL::errstr ($libSQL::cmd)");
				$self->manage_db_error($dbh,"delete_metric_by_id");
	   	   return undef;
   		}
      	$rres=sqlDelete($dbh,'alerts_store',"id_device=$id_dev and mname='$mname'");
      	if ($libSQL::err) {
         	$self->error($libSQL::err);
	         $self->errorstr($libSQL::errstr);
   	      $self->lastcmd($libSQL::cmd);
      	   #$self->log('warning',"delete_metric_by_id::[ERROR] $libSQL::err = $libSQL::errstr ($libSQL::cmd)");
				$self->manage_db_error($dbh,"delete_metric_by_id");
         	return undef;
      	}
		}
      # Elimina la info de metric2snmp
      if ($type eq 'snmp'){
         # Si el dispositivo en cuestion tiene una alerta de sin respuesta snmp, se borra
         # porque si estuviera causada por esta metrica se quedaria colgada y si fuera
         # otra metrica la causante, ya se vlveria a producir.
	      $rres=sqlDelete($dbh,'alerts',"id_device=$id_dev and mname='mon_snmp'");
   	   if ($libSQL::err) {
      	   $self->error($libSQL::err);
         	$self->errorstr($libSQL::errstr);
	         $self->lastcmd($libSQL::cmd);
   	      #$self->log('warning',"delete_metric_by_id::[ERROR] $libSQL::err = $libSQL::errstr ($libSQL::cmd)");
				$self->manage_db_error($dbh,"delete_metric_by_id");
      	   return undef;
      	}
         $rres=sqlDelete($dbh,'metric2snmp',"id_metric in ($id_metric)");
         if ($libSQL::err) {
            $self->error($libSQL::err);
            $self->errorstr($libSQL::errstr);
            $self->lastcmd($libSQL::cmd);
            #$self->log('warning',"delete_metric_by_id::[ERROR] $libSQL::err = $libSQL::errstr ($libSQL::cmd)");
				$self->manage_db_error($dbh,"delete_metric_by_id");
            return undef;
         }


         #//Elimina una posible preasignacion de la metrica al dispositivo
         #delete_assigned_metrics($ip,$subtype);
      }

     # Elimina la info de metric2latency
      elsif ($type eq 'latency'){
         $rres=sqlDelete($dbh,'metric2latency',"id_metric in ($id_metric)");
         if ($libSQL::err) {
            $self->error($libSQL::err);
            $self->errorstr($libSQL::errstr);
            $self->lastcmd($libSQL::cmd);
            #$self->log('warning',"delete_metric_by_id::[ERROR] $libSQL::err = $libSQL::errstr ($libSQL::cmd)");
				$self->manage_db_error($dbh,"delete_metric_by_id");
            return undef;
         }

         #//Elimina una posible preasignacion de la metrica al dispositivo
         #delete_assigned_metrics($ip,$mname);
      }
      elsif ($type eq 'wbem'){
         # Si el dispositivo en cuestion tiene una alerta de sin respuesta snmp, se borra
         # porque si estuviera causada por esta metrica se quedaria colgada y si fuera
         # otra metrica la causante, ya se vlveria a producir.
         $rres=sqlDelete($dbh,'alerts',"id_device=$id_dev and mname='mon_wbem'");
         if ($libSQL::err) {
            $self->error($libSQL::err);
            $self->errorstr($libSQL::errstr);
            $self->lastcmd($libSQL::cmd);
            #$self->log('warning',"delete_metric_by_id::[ERROR] $libSQL::err = $libSQL::errstr ($libSQL::cmd)");
				$self->manage_db_error($dbh,"delete_metric_by_id");
            return undef;
         }
      }

      # Borra el fichero con los datos rrd
      if (-f $frrd) {
         my $rc=unlink ($frrd);
         if (! $rc) {
				$self->log('warning',"delete_metric_by_id::[ERROR] ERROR al borrar RRD $frrd");
			}
      }

	}

	# Elimina la metrica de la tabla metrics
   $rres=sqlDelete($dbh,"$TAB_METRICS_NAME","$condition");
   if ($libSQL::err) {
      $self->error($libSQL::err);
      $self->errorstr($libSQL::errstr);
      $self->lastcmd($libSQL::cmd);
      #$self->log('warning',"delete_metric_by_id::[ERROR] $libSQL::err = $libSQL::errstr ($libSQL::cmd)");
		$self->manage_db_error($dbh,"delete_metric_by_id");
      return undef;
   }

   return 1;
}

#----------------------------------------------------------------------------
# Funcion: delete_metric_relations
# Descripcion:
# $table sera metric2latency, metric2agent, metric2snmp
#----------------------------------------------------------------------------
sub delete_metric_relations {
my ($self,$dbh)=@_;

	my @TAB=qw (metric2snmp metric2latency metric2agent);
	my $condition='id_metric not in (select id_metric from metrics)';
	foreach my $table (@TAB) {
   	my $rres=sqlDelete($dbh,$table,$condition);
		if ($libSQL::err) {
		   $self->error($libSQL::err);
   		$self->errorstr($libSQL::errstr);
   		$self->lastcmd($libSQL::cmd);
			#$self->log('warning',"delete_metric_relations::[ERROR] $libSQL::err = $libSQL::errstr ($libSQL::cmd)");
			$self->manage_db_error($dbh,"delete_metric_relations");
			last;
		}
	}
}

#----------------------------------------------------------------------------
# Funcion: delete_from_template_metrics
# Descripcion:
#----------------------------------------------------------------------------
sub delete_from_template_metrics {
my ($self,$dbh,$id_dev,$type)=@_;


#select a.id_template_metric from prov_template_metrics a, prov_template_metrics2iid b where a.id_template_metric=b.id_template_metric and a.id_dev=692 and a.type='snmp';

   my $values='a.id_template_metric';
   my $table='prov_template_metrics a, prov_template_metrics2iid b';
   my $where="a.id_template_metric=b.id_template_metric and a.id_dev=$id_dev and a.type=\'$type\'";
   my $rres=sqlSelectAll($dbh,$values,$table,$where);

	my @ids=();
   foreach my $m (@$rres) { push @ids, $m->[0]; }

	if (scalar(@ids)==0) { return; }


	my $list_ids=join(',',@ids);
   my @TAB=qw (prov_template_metrics2iid prov_template_metrics);
 	$where = "id_template_metric in ($list_ids)";

	$self->log('info',"delete_from_template_metrics:: where $where");	
   foreach my $table (@TAB) {
      my $rres=sqlDelete($dbh,$table,$where);
      if ($libSQL::err) {
         $self->error($libSQL::err);
         $self->errorstr($libSQL::errstr);
         $self->lastcmd($libSQL::cmd);
         #$self->log('warning',"delete_from_template_metrics::[ERROR] $libSQL::err = $libSQL::errstr ($libSQL::cmd)");
			$self->manage_db_error($dbh,"delete_from_template_metrics");
         last;
      }
   }

}

#----------------------------------------------------------------------------
# Funcion: update_metrics
# Descripcion:
#----------------------------------------------------------------------------
sub update_metrics {
my ($self,$dbh,$data)=@_;
my %table=();
my $rv=undef;
my $condition='';

   if (defined $data->{id_metric}) {
		$condition="id_metric=$data->{id_metric}";
	}
   elsif (defined $data->{id_dev}) {
      $condition="id_dev=$data->{id_dev}";
		if (defined $data->{name}) { $condition.=" && name=$data->{name}"; }
   }
   elsif (defined $data->{crawler_idx}) {
      $condition="crawler_idx=$data->{crawler_idx}";
   }
   elsif (defined $data->{lapse}) {
      $condition="lapse=$data->{lapse}";
   }
   else {return undef;}


   if (defined $data->{name}) {$table{name}= $data->{name};}
   if (defined $data->{type}) {$table{type}= $data->{type};}
   if (defined $data->{subtype}) {$table{subtype}=$data->{subtype};}
   if (defined $data->{label}) {$table{label}=$data->{label};}
   if (defined $data->{items}) {$table{items}=$data->{items};}
   if (defined $data->{lapse}) {$table{lapse}=$data->{lapse};}
   if (defined $data->{file_path}) {$table{file_path}=$data->{file_path};}
   if (defined $data->{file}) {$table{file}=$data->{file};}
   if (defined $data->{host}) {$table{host}=$data->{host};}
   if (defined $data->{vlabel}) {$table{vlabel}=$data->{vlabel};}
   if (defined $data->{graph}) {$table{graph}=$data->{graph};}
   if (defined $data->{mtype}) {$table{mtype}=$data->{mtype};}
   if (defined $data->{status}) {$table{status}=$data->{status};}
   if (defined $data->{crawler_idx}) {$table{crawler_idx}=$data->{crawler_idx};}
   if (defined $data->{crawler_pid}) {$table{crawler_pid}=$data->{crawler_pid};}
	if (defined $data->{watch}) {$table{watch}=$data->{watch};}
	if (defined $data->{refresh}) {$table{refresh}=$data->{refresh};}
	if (defined $data->{disk}) {$table{disk}=$data->{disk};}
	if (defined $data->{c_label}) {$table{c_label}=$data->{c_label};}
	if (defined $data->{c_items}) {$table{c_items}=$data->{c_items};}
	if (defined $data->{c_vlabel}) {$table{c_vlabel}=$data->{c_vlabel};}
	if (defined $data->{c_mtype}) {$table{c_mtype}=$data->{c_mtype};}

   $rv=sqlUpdate($dbh,$TAB_METRICS_NAME,\%table,$condition);

   $self->error($libSQL::err);
   $self->errorstr($libSQL::errstr);
   $self->lastcmd($libSQL::cmd);

   if ($libSQL::err) {
		#$self->log('warning',"update_metrics::[ERROR] update metrics $condition ($libSQL::err)");
		$self->manage_db_error($dbh,"update_metrics");
      return undef;
   }

   return $rv;

}

#----------------------------------------------------------------------------
# Funcion: get_all_devices
# Descripcion:
# @=(id,n,ip ...)
#----------------------------------------------------------------------------
sub get_all_devices {
my ($self,$dbh)=@_;
my @rv=();

   my $rs=sqlSelectAll($dbh,'id_dev,name,ip,status',$TAB_DEVICES_NAME);
	return $rs;
   #foreach my $l (@$rs){
   #   foreach my $v (@$l) { push @rv,$v; }
   #}
   #return \@rv;
}




#----------------------------------------------------------------------------
# Funcion: update_device
# Descripcion:
#----------------------------------------------------------------------------
sub update_device {
my ($self,$dbh,$data)=@_;
my %table=();
my $rv=undef;

   if (defined $data->{id_dev}) { $table{id_dev}=$data->{id_dev}; }
   else {return;}

   if (defined $data->{name}) {$table{name}= lc $data->{name};}
   if (defined $data->{domain}) {$table{domain}= lc $data->{domain};}
   if (defined $data->{ip}) {$table{ip}=$data->{ip};}
   if (defined $data->{sysloc}) {$table{sysloc}=$data->{sysloc};}
   if (defined $data->{sysdesc}) {$table{sysdesc}=$data->{sysdesc};}
   if (defined $data->{sysoid}) {$table{sysoid}=$data->{sysoid};}
   if (defined $data->{txml}) {$table{txml}=$data->{txml};}
   if (defined $data->{type}) {$table{type}=$data->{type};}
   if (defined $data->{app}) {$table{app}=$data->{app};}
	if (defined $data->{version}) {$table{version}=$data->{version};}
   if (defined $data->{status}) {$table{status}=$data->{status};}
	

   $rv=sqlUpdate($dbh,$TAB_DEVICES_NAME,\%table,"id_dev=$table{id_dev}");

   $self->error($libSQL::err);
   $self->errorstr($libSQL::errstr);
   $self->lastcmd($libSQL::cmd);

   if ($libSQL::err) {
      #$self->log('warning',"update_device::[WARN] Error en Update device $table{id_dev} (RV=undef)");
		$self->manage_db_error($dbh,"update_device");
   }
	else {
		$self->log('debug',"update_device::[DEBUG] Update device $table{id_dev} (RV=$rv)");
	}
   return $rv;

}

#----------------------------------------------------------------------------
# Funcion: update_alerts
# Descripcion:
#----------------------------------------------------------------------------
sub update_alerts {
my ($self,$dbh,$data)=@_;
my %table=();
my $rv=undef;

   if (defined $data->{id_alert}) { $table{id_alert}=$data->{id_alert}; }
   else {return;}

   if (defined $data->{watch}) {$table{watch}= $data->{watch};}
   if (defined $data->{severity}) {$table{severity}= $data->{severity};}
   if (defined $data->{date}) {$table{date}=$data->{date};}
   if (defined $data->{ack}) {$table{ack}=$data->{ack};}
   if (defined $data->{counter}) {$table{counter}=$data->{counter};}
   if (defined $data->{event_data}) {$table{event_data}=$data->{event_data};}
   if (defined $data->{notif}) {$table{notif}=$data->{notif};}

   $rv=sqlUpdate($dbh,$TAB_ALERTS_NAME,\%table,"id_alert=$table{id_alert}");
   if (defined $rv) {
      $self->log('debug',"update_alerts::[DEBUG] Update alerts $table{id_alert} (RV=$rv)");
	}
   else {
      $self->log('warning',"update_alerts::[WARN] Error en Update $table{id_alert} (RV=undef)");
   }
   return $rv;
}

#----------------------------------------------------------------------------
# Funcion: store_alert2response
# Descripcion:
#----------------------------------------------------------------------------
sub store_alert2response {
my ($self,$dbh,$data)=@_;

	my %table=('id_alert'=>0, 'type'=>1, 'descr'=>'', 'rc'=>0, 'rcstr'=>'', 'info'=>'');
   if (defined $data->{id_alert}) { $table{id_alert}=$data->{id_alert}; }
   else {return;}

   if (defined $data->{'type'}) {$table{'type'}=$data->{'type'};}
   if (defined $data->{'descr'}) {$table{'descr'}=$data->{'descr'};}
   if (defined $data->{'rc'}) {$table{'rc'}=$data->{'rc'};}
   if (defined $data->{'rcstr'}) {$table{'rcstr'}=$data->{'rcstr'};}
   if (defined $data->{'info'}) {$table{'info'}=$data->{'info'};}
   if (defined $data->{'date'}) {$table{'date'}=$data->{'date'};}
	else { $table{'date'}=time(); }

   #------------------------------------------------------------------------
   my $rv=sqlInsertUpdate4x($dbh,'alert2response',\%table,\%table);
   $self->error($libSQL::err);
   $self->errorstr($libSQL::errstr);
	$libSQL::cmd =~ s/\n/ \./g;
   $self->lastcmd($libSQL::cmd);

	$self->log('debug',"store_alert2response:: **DEBUG**  ($libSQL::cmd)");

   if ($libSQL::err) {
      #$self->log('warning',"store_alert2response::[WARN] ERROR $libSQL::err  ($libSQL::cmd)");
		$self->manage_db_error($dbh,"store_alert2response");
      return undef;
   }
	return $rv;

}

#----------------------------------------------------------------------------
# Funcion: store_alert_type
# Descripcion:
#----------------------------------------------------------------------------
sub store_alert_type {
my ($self,$dbh,$data)=@_;
my %table=();
my $rv=undef;
my $monitor='';


   if (defined $data->{cause}) { $table{cause}=$data->{cause}; }
   else {
		$self->error(1);	
		$self->errorstr('No definido campo cause');	
		return;
	}

   if (defined $data->{monitor}) { $table{monitor}=$data->{monitor}; }
	else {
      $self->error(1);
      $self->errorstr('No definido campo monitor');
		return;
	}
	if ($data->{monitor} =~ /^s_/) {
		#expr s_disk_mibhost_2005 (v1/v2)*100>10
		if (defined $data->{expr}) { $table{expr}=$data->{expr}; }
		else {
	      $self->error(1);
   	   $self->errorstr('No definido campo expr');
			return;
		}
	
	}
	elsif ($data->{monitor} =~ /^w_/) {
		#params w_mon_imap_2003  u=fmarinla|p=gcyr69|port=143
		if (defined $data->{params}) { $table{params}=$data->{params}; }
		else {
         $self->error(1);
         $self->errorstr('No definido campo params');
			return;
		}

	}
	else {
      $self->error(1);
      $self->errorstr('Mal definido campo monitor');
		return;
	}

   $table{severity} = (defined $data->{severity}) ? $data->{severity} : 1;

	if (defined $data->{mname}) { $table{mname}=$data->{mname}; }

	my $table=$TAB_ALERT_TYPE_NAME;
	my $where="monitor=\'$table{monitor}\'";
	my $what='id_alert_type';;
   $rv=sqlInsertUpdate($dbh,$table,\%table,$where,$what);

   $self->error($libSQL::err);
   $self->errorstr($libSQL::errstr);
   $self->lastcmd($libSQL::cmd);
	my $sql_previo=$libSQL::cmd;

   if ($libSQL::err) {
      #$self->log('debug',"store_alert_type::[ERROR] $libSQL::cmd");
      #$self->log('debug',"store_alert_type::[ERROR] ($libSQL::err)");
		$self->manage_db_error($dbh,"store_alert_type");
		return undef;
   }


   $where="id_alert_type=$rv->[0][0]";
	%table=();
	$table{monitor}=$data->{monitor}.'_'.$rv->[0][0];
	$monitor=$table{monitor};
   $rv=sqlUpdate($dbh,$table,\%table,$where);

   $self->error($libSQL::err);
   $self->errorstr($libSQL::errstr);
   $self->lastcmd("$sql_previo\n$libSQL::cmd");

   if ($libSQL::err) {
      #$self->log('debug',"store_alert_type::[ERROR] $libSQL::cmd");
      #$self->log('debug',"store_alert_type::[ERROR] ($libSQL::err)");
		$self->manage_db_error($dbh,"store_alert_type");
      return undef;
   }

   return $monitor;
}


#----------------------------------------------------------------------------
# get_device2log
# SELECT d.id_dev,d.ip,d.name,d.domain,d.critic,l.logfile,l.todb,l.script,l.date_store,c.name,c.type,c.user,c.pwd,c.port FROM  device2log l, devices d, credentials c WHERE l.id_dev=d.id_dev AND l.id_credential=c.id_credential
#----------------------------------------------------------------------------
sub get_device2log {
my ($self,$dbh,$data)=@_;
my %table=();
my $rv=undef;
my $values="d.id_dev,d.ip,d.name,d.domain,d.critic,l.logfile,l.todb,l.script,l.last_access,l.last_line,l.parser,c.name,c.type,c.user,c.pwd,c.port,l.tabname";
my $tables='device2log l, devices d, credentials c';
my $condition='l.id_dev=d.id_dev AND l.id_credential=c.id_credential AND l.status=0';

   my $rres=sqlSelectAll($dbh,$values,$tables,$condition);

   $self->error($libSQL::err);
   $self->errorstr($libSQL::errstr);
   $self->lastcmd($libSQL::cmd);

   if ($libSQL::err) {
      $self->manage_db_error($dbh,"get_device2log");
      return undef;
   }

   return $rres;
}

#----------------------------------------------------------------------------
# set_device2log
#----------------------------------------------------------------------------
sub set_device2log {
my ($self,$dbh,$data)=@_;

#PRIMARY KEY (`id_dev`,`logfile`)

   my $table = 'device2log';
   my $condition = 'id_dev='.$data->{'id_dev'}.' AND logfile="'.$data->{'logfile'}.'"';

   if (! defined $dbh) { return undef; }
   my $rres=sqlUpdate($dbh, $table, $data, $condition);

   $self->error($libSQL::err);
   $self->errorstr($libSQL::errstr);
   $self->lastcmd($libSQL::cmd);

   if ($libSQL::err) {
      $self->manage_db_error($dbh,"set_device2log");
      return undef;
   }

   return 0;
}

#'device2log_insert'=>"INSERT INTO device2log (id_dev,id_credential,logfile,todb,status,parser) VALUES (__ID_DEV__,__ID_CREDENTIAL__,'__LOGFILE__',__TODB__,__STATUS__,'__PARSER__')",

#----------------------------------------------------------------------------
# init_device2log
# Campos de $data:
# id_dev,id_credential,logfile,todb,status,parser
#----------------------------------------------------------------------------
sub init_device2log {
my ($self,$dbh,$data)=@_;

   if (! defined $dbh) { return undef; }

   # apps with flush mode ==> Insert in logp_xxxxx_temp table
   # but descriptor must be logp_xxxxx
   if ($data->{'logfile'} =~ /^(\S+)_temp$/) { $data->{'logfile'} = $1; }
   if ($data->{'tabname'} =~ /^(\S+)_temp$/) { $data->{'tabname'} = $1; }

$self->log('info',"init_device2log::DEBUG**>> INSERTO en device2log tabname=$data->{'tabname'}---logfile=$data->{'logfile'}");


   my $rv=sqlInsertUpdate4x($dbh,'device2log',$data,$data);

   $self->error($libSQL::err);
   $self->errorstr($libSQL::errstr);
   $self->lastcmd($libSQL::cmd);

   if ($libSQL::err) {
      $self->manage_db_error($dbh,"init_device2log");
      return undef;
   }

   return 0;

}

#----------------------------------------------------------------------------
# Funcion: store_cfg_assigned_metric_new
# Descripcion:
#----------------------------------------------------------------------------
sub store_cfg_assigned_metric_new {
my ($self,$dbh,$data)=@_;
my $rv=undef;

	my @params=qw( lapse subtype monitor active_iids );
	my $table=$self->validate_params( \@params, $data);
	if (! defined $table) { return; }

   $table->{myrange} = (defined $data->{range}) ? $data->{range} : '';
   $table->{include} = (defined $data->{include}) ? $data->{include} : 1;

   if (!defined $data->{type}) {
      if ($table->{monitor} =~ /^s_/)  {$table->{type}='snmp';}
      elsif ($table->{monitor} =~ /^w_/)  {$table->{type}='latency';}
      else {
         $self->error(1);
         $self->errorstr("De $table->{monitor} no se puede obtener el type");
			return;
		}
   }
   else { $table->{type} = $data->{type}; }




	if (!defined $data->{id_type}) {
   	if ($table->{range} =~ /\d+\.\d+\.\d+\.\d+/)  {$table->{id_type}='ip';}
   	elsif ($table->{range} =~ /[\d+\.]+/)  {$table->{id_type}='oid';}
   	else { $table->{id_type}='type';}
	}
	else { $table->{id_type} = $data->{id_type}; }

   my $where="myrange=\'$table->{myrange}\'";
   my $what='id_assigned_metric';
   $rv=sqlInsertUpdate($dbh,$TAB_CFG_ASSIGNED_METRICS_NAME,$table,$where,$what);

   $self->error($libSQL::err);
   $self->errorstr($libSQL::errstr);
   $self->lastcmd($libSQL::cmd);

   if ($libSQL::err) {
      #$self->log('debug',"store_assigned_metric::[ERROR] $libSQL::cmd");
      #$self->log('debug',"store_assigned_metric::[ERROR] ($libSQL::err)");
		$self->manage_db_error($dbh,"store_assigned_metric");
      return undef;
   }

   return $rv;
}



#----------------------------------------------------------------------------
# prepare_graph_data_compact_block
#
# CREATE TABLE `__raw__1__latency__mon_icmp` (
#  `id_dev` int(11) NOT NULL,
#  `ts_line` int(11) NOT NULL,
#  `v1` varchar(2048) default NULL,
#  `hiid` varchar(32) NOT NULL default 'ALL',
#  PRIMARY KEY  (`id_dev`,`hiid`,`ts_line`),
#  KEY `id_dev_idx` (`id_dev`),
#  KEY `ts_line_idx` (`ts_line`)
#) ENGINE=MyISAM DEFAULT CHARSET=latin1
#
# A partir de la tabla raw crea tambien ña tabla store
#----------------------------------------------------------------------------

sub prepare_graph_data_compact_block {
my ($self,$dbh,$table,$mode)=@_;
my %table=();
my $rv=undef;

   # ------------------------------------------------------
   # __raw__000__1__latency__w_mon_dns_e26ca9da
   my $nitems=0;
   if ($table =~ /__\w+__\d+__(\d+)__/) { $nitems = $1; }

   my $fields_create='id_dev int NOT NULL, ts_line int NOT NULL, hiid  varchar(32) NOT NULL default "ALL", ';
   for my $i (1..$nitems) {
      my $k='v'.$i;
      $fields_create.="$k varchar(2048) NOT NULL, ".$k.'avg float NOT NULL default 0, '.$k.'max float NOT NULL default 0, '.$k.'min float NOT NULL default 0, ';
   }
   $fields_create.=' PRIMARY KEY (id_dev,hiid,ts_line), KEY id_dev_idx (id_dev), KEY ts_line_idx (ts_line)';

   sqlCreate($dbh,$table,$fields_create);
   $self->error($libSQL::err);
   $self->errorstr($libSQL::errstr);
   $self->lastcmd($libSQL::cmd);
   $self->log('info',"prepare_graph_data_compact_block::[INFO] CREADA TABLA $table ($libSQL::err $libSQL::errstr) (CMD=$libSQL::cmd)");

   # Se crea la tabla store
   $table =~ s/^__\w+__(\d{3}__\d__.+)$/__store__$1/;
   sqlCreate($dbh,$table,$fields_create);
   $self->error($libSQL::err);
   $self->errorstr($libSQL::errstr);
   $self->lastcmd($libSQL::cmd);
   $self->log('info',"prepare_graph_data_compact_block::[INFO] MODE=$mode CREADA TABLA $table ($libSQL::err $libSQL::errstr) (CMD=$libSQL::cmd)");

   if ($mode eq 'COUNTER') {
      # Se crea la tabla de scratch para metricas diferenciales (tipo counter)
      $table =~ s/^__\w+__(\d{3}__\d__.+)$/__scratch__$1/;
      $fields_create='id_dev int NOT NULL, hiid  varchar(32) NOT NULL default "ALL", ts int NOT NULL, data varchar(255) NOT NULL, PRIMARY KEY (id_dev,hiid)';
      sqlCreate($dbh,$table,$fields_create);
      $self->error($libSQL::err);
      $self->errorstr($libSQL::errstr);
      $self->lastcmd($libSQL::cmd);
      $self->log('info',"prepare_graph_data_compact_block::[INFO] CREADA TABLA $table ($libSQL::err $libSQL::errstr) (CMD=$libSQL::cmd)");
   }

}

#----------------------------------------------------------------------------
#----------------------------------------------------------------------------
sub get_graph_data_scratch {
my ($self,$dbh,$table)=@_;
my %vector=();

   my $rres=sqlSelectAll($dbh,'id_dev,ts,hiid,data',$table,'','');
   foreach my $m (@$rres) {
      my $id_dev=$m->[0];
      my $ts=$m->[1];
      my $hiid=$m->[2];
      my $data=$m->[3];
		my $key="$id_dev-$hiid";
		#$vector{$key}={'id_dev'=>$id_dev, 'ts'=>$ts, 'hiid'=>$hiid, 'subtype'=>$subtype, 'data=>$data'};
		#Interesa un array para luego hacer el update con placeholders de forma mas natural
		$vector{$key}=[$id_dev, $ts, $hiid, $data, $ts, $data];
	}
	return \%vector;
}

#----------------------------------------------------------------------------
#----------------------------------------------------------------------------
sub store_graph_data_scratch {
my ($self,$dbh,$table,$data)=@_;

	my $sql="INSERT INTO $table (id_dev,ts,hiid,data) VALUES (?,?,?,?) ON DUPLICATE KEY UPDATE  ts=?, data=?";
   my $rv=sqlCmd_fast($dbh,$data,$sql);

   $self->error($libSQL::err);
   $self->errorstr($libSQL::errstr);
   $self->lastcmd($libSQL::cmd);

   if ($libSQL::err) {
      #$self->log('warning',"store_graph_data_scratch::[WARN] ERROR $libSQL::err  $libSQL::errstr ($libSQL::cmd)");
		$self->manage_db_error($dbh,"store_graph_data_scratch");
      return undef;
   }


}

#----------------------------------------------------------------------------
#----------------------------------------------------------------------------
#----------------------------------------------------------------------------
#----------------------------------------------------------------------------
# Procesa en bloques
#
# $data_vector es un array de la forma (para cada subtype):
#  [
#                          {
#                            'data' => '1281522011:0.002307',
#                            'iddev' => '181',
#                            'iid' => ''
#                          },
#                          .....
#                          {
#                            'data' => '1281522011:0.050355',
#                            'iddev' => '520',
#                            'iid' => ''
#                          },
#  ]
#----------------------------------------------------------------------------
#----------------------------------------------------------------------------
sub load_raw_graph_data {
my ($self,$dbh,$mode,$lapse,$type,$subtype,$subtable,$data_vector)=@_;
my %table=();
my $rv=undef;
my ($key, $table_scratch);

#fml parche
#if ($subtype eq 'disp_icmp') { return; }
	
	if ($lapse !~ /\d+/) { $lapse=60; }

   # ------------------------------------------------------
   my @d=split(':',$data_vector->[0]->{'data'});
   my $ts=shift @d;
   my $nitems = scalar(@d);

   # ------------------------------------------------------
   my $table='__raw__'.$subtable.'__'.$nitems.'__'.$type.'__'.$subtype;
   my $ts_line = (int($ts/3600))*3600; #Filas por hora

   # ------------------------------------------------------
#| id_dev | ts_line       |  v1                                                  | hiid     |

   my @fields_select=();
   my @avg_min_max=();
   my $i=1;
   foreach my $v (@d) {
      my $k='v'.$i;
      push @fields_select, $k;
      push @avg_min_max, $k.'avg';
      push @avg_min_max, $k.'max';
      push @avg_min_max, $k.'min';

#      # U equivale a NaN y lo hacemos equivaler a NULL
#      if ($v eq 'U') { $table_data{$k}=undef; }
#      else { $table_data{$k}=$v;  }
      $i+=1;
   }
   push @fields_select, @avg_min_max;

my $t1=time;


   # ------------------------------------------------------
   # Si la metrica es de tipo COUNTER tengo que utilizar el ultimo
   # valor absoluto almacenado en la tabla scratch.
   my $SCRATCH;
	if ($mode eq 'COUNTER') {
   	$table_scratch='__scratch__'.$subtable.'__'.$nitems.'__'.$type.'__'.$subtype;
		$SCRATCH=$self->get_graph_data_scratch($dbh,$table_scratch);
	}

   # ------------------------------------------------------
   # Obtengo los valores ya almacenados para este rango $ts_line
   my @id_dev_vector=();
   foreach my $v (@$data_vector) { push @id_dev_vector, $v->{'iddev'}; }
   my $id_devs=join(",", @id_dev_vector);
   my $what='ts_line,id_dev,hiid,'. join(',',@fields_select);
   my $where="id_dev in ($id_devs) and ts_line=$ts_line";
   my $other='';
   my $rres=sqlSelectAll($dbh,$what,$table,$where,$other);

   $self->lastcmd($libSQL::cmd);

   if (ref($rres) ne "ARRAY") {
      $self->prepare_graph_data_compact_block($dbh,$table,$mode);
      return;
   }

#print "SQL=$libSQL::cmd\n";

   my $nlines=scalar(@$rres);

#print "NLINES=$nlines\n";


my $tdif=time-$t1;
$self->log('warning',"load_raw_graph_data:: ($mode) GET-DATA EN $table (elapsed=$tdif)");
	
   my %done=();
   my @data=();
   # ------------------------------------------------------
   # ------------------------------------------------------
   # Si hay datos => EXISTE CHUNCK
   # ------------------------------------------------------
   # ------------------------------------------------------
   if ($nlines >0) {
			
		# Preparamos el vector de datos 			
      foreach my $l (0..$nlines-1) {

         # [$l][0] ts_line
         # [$l][1] id_dev
         # [$l][2] hiid
         # [$l][3] v1     0 +3
         # [$l][4] v2     1
         # [$l][5] v1avg
         # [$l][6] v1max
         # [$l][7] v1min
         # [$l][8] v2avg
         # [$l][9] v2max
         # [$l][10] v2min

         $done{$rres->[$l][1]}=1;

			#Para el caso COUNTER obtengo el ultimo valor absoluto almacenado
			my @scratch_data=();
			my @new_scratch_data=();
			if ($mode eq 'COUNTER') {
				# $SCRATCH->{$key}=[$id_dev, $ts, $hiid, $data, $ts, $data]
				$key=$rres->[$l][1].'-'.$rres->[$l][2];
				$SCRATCH->{$key}->[0]=$rres->[$l][1];
				$SCRATCH->{$key}->[2]=$rres->[$l][2];
				if (exists $SCRATCH->{$key}->[3]) {
					@scratch_data=split(':',$SCRATCH->{$key}->[3]);
				}
$self->log('info',"load_raw_graph_data:: $table DEBUG SCRATCH U (1) key=$key scratch_data=@scratch_data");
			}
			
         # ------------------------------------------------------
         # Hay datos => Tengo que actualizar el chunk. Preparo el vector
         # ------------------------------------------------------
         for my $i (0..$nitems-1) {
            my $idx=$i+3; #Posicion relativa de cada valor v1, v2 ...
            my $data_stored=$rres->[$l][$idx];
            my $values = $self->_data_untar($data_stored,$lapse);
				
            # ------------------------------------------------------
            my $data_new='';
            foreach my $item (@$data_vector) {
               if ( ($item->{'iddev'} == $rres->[$l][1]) && ($item->{'iid'} eq $rres->[$l][2]) )    {
                  $data_new=$item->{'data'};
                  last;
               }
            }
				
            # ------------------------------------------------------
            # ------------------------------------------------------

            # ------------------------------------------------------
            # Se normaliza el timestamp a minuto ($TS)
            # Si valor>30 se pone el siguiente minuto
            my @d=split(':',$data_new);
            my $ts = shift @d;
            my $ts_sample = $self->round_time($ts,$lapse);
				if ($mode eq 'COUNTER') { 
					$SCRATCH->{$key}->[1]=$ts_sample;
					if (($d[$i] =~ /\d+/) && (exists $scratch_data[$i]) && ($scratch_data[$i] =~ /\d+/)) {
						# Se calcula la diferencia y se normaliza el eje de tiempos (ts_sample-ts_scratch)
						my @time_lapses = sort keys %$values;
						my $n=scalar(@time_lapses);
						my $div=$ts_sample-$time_lapses[$n-1];
$self->log('info',"load_raw_graph_data:: $table DEBUG SCRATCH U (2) key=$key time_lapses=@time_lapses");
						if ($div <=0) {$div=1;}
						my $aux=($d[$i]-$scratch_data[$i])/$div; 
						$values->{$ts_sample} = ($aux>1) ? sprintf("%.3f",$aux) : $aux;
	
$self->log('info',"load_raw_graph_data:: $table DEBUG SCRATCH U (3) key=$key value = $d[$i] - $scratch_data[$i] / $ts_sample - $time_lapses[$n-1] ($values->{$ts_sample})");
					}
					else { $values->{$ts_sample}='U'; }
					$new_scratch_data[$i]=$d[$i];
$self->log('info',"load_raw_graph_data:: $table DEBUG SCRATCH U (4) key=$key value = $values->{$ts_sample} new_scratch_data=$new_scratch_data[$i]");

				}
				else { 
					$values->{$ts_sample} = (($d[$i] =~ /\d+/)&&($d[$i]>1)) ? sprintf("%.3f",$d[$i]) : $d[$i]; 
				}

            my $idx_avg=$idx+$nitems*($i+1);
            ($rres->[$l][$idx],$rres->[$l][$idx_avg],$rres->[$l][$idx_avg+1],$rres->[$l][$idx_avg+2]) = $self->_data_tar($values);

if ($mode eq 'COUNTER') {
$self->log('info',"load_raw_graph_data:: $table DEBUG SCRATCH U (5) key=$key rres >>  ($rres->[$l][$idx], $rres->[$l][$idx_avg], $rres->[$l][$idx_avg+1], $rres->[$l][$idx_avg+2])");
}

         } #nitems

			if ($mode eq 'COUNTER') {
				$SCRATCH->{$key}->[3] = join(':', @new_scratch_data); #Actualizo los valores de scratch
				#$SCRATCH->{$key}->[1] = $rres->[$l][0];					#Actualizo el ts los valores de scratch
				$SCRATCH->{$key}->[4] = $SCRATCH->{$key}->[1];
				$SCRATCH->{$key}->[5] = $SCRATCH->{$key}->[3];
$self->log('info',"load_raw_graph_data:: $table DEBUG SCRATCH U (6) key=$key new_scratch_data=@new_scratch_data");
			}

      }
      # ------------------------------------------------------
      # UPDATE
      # ------------------------------------------------------
      @data=();
      foreach my $l (0..$nlines-1) {

         # [$l][0] ts_line
         # [$l][1] id_dev
         # [$l][2] hiid
         # [$l][3] v1     0 +3
         # [$l][4] v2     1
         # [$l][5] v1avg
         # [$l][6] v1max
         # [$l][7] v1min
         # [$l][8] v2avg
         # [$l][9] v2max
         # [$l][10] v2min

         my @line=();
         for my $i (0..$nitems-1) {
            push @line, $rres->[$l][3+$i];
         }
         my $j=3+$nitems;
         for my $i (0..$nitems-1) {
            push @line, $rres->[$l][$j];
            push @line, $rres->[$l][$j+1];
            push @line, $rres->[$l][$j+2];
            $j+=3;
         }

         push @line,$rres->[$l][1];
         push @line,$ts_line;
         push @line,$rres->[$l][2];

         #push @data, [$rres->[$l][3], $rres->[$l][1], $ts_line, $rres->[$l][2]];
         push @data, \@line;
         $done{$rres->[$l][1]}=1;
      }

      my @sets=();
      for my $i (1..$nitems) {
         push @sets, "v$i=?";
      }
      for my $i (1..$nitems) {
         push @sets, "v$i".'avg=?';
         push @sets, "v$i".'max=?';
         push @sets, "v$i".'min=?';
      }

      #my $sql="UPDATE $table SET v1=? WHERE id_dev=? AND ts_line=? AND hiid=?";
      my $sql="UPDATE $table SET ". join(',',@sets) . " WHERE id_dev=? AND ts_line=? AND hiid=?";

      $rv=sqlCmd_fast($dbh,\@data,$sql);


      $self->error($libSQL::err);
      $self->errorstr($libSQL::errstr);
      $self->lastcmd($libSQL::cmd);

      if ($libSQL::err != 0) {
         $self->log('warning',"load_raw_graph_data::[WARN] Error en Update de $table ($sql) (RV=undef)");
      }
   }
	
   # ------------------------------------------------------
   # No hay datos => NO EXISTE CHUNK (es nuevo)
   # ------------------------------------------------------
   my $c1=scalar(@data);
   @data=();
   foreach my $l (@$data_vector) {


#                          {
#                            'data' => '1281522011:0.002307',
#                            'iddev' => '181',
#                            'iid' => ''
#                          },


      my $id_dev=$l->{'iddev'};
      if (exists $done{$id_dev}) { next; }

      #Para el caso COUNTER obtengo el ultimo valor absoluto almacenado
      my @scratch_data=();
      my @new_scratch_data=();
      if ($mode eq 'COUNTER') {
         $key=$l->{'iddev'}.'-'.$l->{'iid'};
         @scratch_data=split(':',$SCRATCH->{$key}->[3]);
$self->log('info',"load_raw_graph_data:: $table DEBUG SCRATCH I (1) key=$key scratch_data=@scratch_data");
      }

      # ------------------------------------------------------
      # Se normaliza el timestamp a minuto ($TS)
      # Si valor>30 se pone el siguiente minuto
      my @d=split(':',$l->{'data'});
      my $ts = shift @d;
      my $ts_sample = $self->round_time($ts,$lapse);

$self->log('info',"load_raw_graph_data:: $table DEBUG SCRATCH I (1-1) FIRST data=$l->{data} ts_sample=$ts_sample");

      my @vx=();
      my @avg_max_min=();
      my $j=0;
      for my $i (0..$nitems-1) {

			if (!defined $d[$i]) { next; }
         #my $x='v'.$i+1;
         if ($mode eq 'COUNTER') {
				#fml hay que buscar el ultimo valor de la serie de la hora anterior
            #my $div=$ts_sample-$ts_1;
            # fml!! ANALIZAE EL CASO EN QUE ALGUN VALOR SEA U
            my $div=300;
            if ($div <=0) {$div=1;}
            my $aux=($d[$i]-$scratch_data[$i])/$div;
				my $first_val = ($aux>1) ? sprintf("%.3f",$aux) : $aux;
$self->log('info',"load_raw_graph_data:: $table DEBUG SCRATCH I (2) key=$key first_value = $d[$i] - $scratch_data[$i] / $div ($first_val)");

            ($vx[$i],$avg_max_min[$j],$avg_max_min[$j+1],$avg_max_min[$j+2]) = $self->_data_tar( {$ts_sample => $first_val} );
				$new_scratch_data[$i]=$d[$i];
         }
         else {

				my $aux = (($d[$i] =~ /\d+/)&&($d[$i]>1)) ? sprintf("%.3f",$d[$i]) : $d[$i];
            ($vx[$i],$avg_max_min[$j],$avg_max_min[$j+1],$avg_max_min[$j+2]) = $self->_data_tar( {$ts_sample => $aux} );
         }
         $j+=3;
      }
      push @data, [$id_dev, $ts_line, $l->{'iid'}, @vx, @avg_max_min ];

      if ($mode eq 'COUNTER') {
         $SCRATCH->{$key}->[3] = join(':', @new_scratch_data); #Actualizo los valores de scratch
         $SCRATCH->{$key}->[1] = $ts_sample; 	              	#Actualizo el ts los valores de scratch
         $SCRATCH->{$key}->[4] = $SCRATCH->{$key}->[1];
         $SCRATCH->{$key}->[5] = $SCRATCH->{$key}->[3];
      }

   }

	# Se almacenan los datos en la tabla raw
   my $c2=scalar(@data);
   #Inserto si tengo valores para insertar.
   if ($c2>0) {

      my @names=('id_dev','ts_line','hiid');
      my @values=('?','?','?');
      for my $i (1..$nitems) {
         push @names, "v$i";
         push @values, '?';
      }
      for my $i (1..$nitems) {
         push @names, "v$i".'avg';
         push @values, '?';
         push @names, "v$i".'max';
         push @values, '?';
         push @names, "v$i".'min';
         push @values, '?';
      }

     #my $sql="INSERT INTO $table (id_dev,ts_line,hiid,v1) VALUES (?,?,?,?)";
      my $sql='INSERT INTO '.$table. ' (' . join(',',@names). ') VALUES ('. join(',',@values).')';

      $rv=sqlCmd_fast($dbh,\@data,$sql);

      $self->error($libSQL::err);
      $self->errorstr($libSQL::errstr);
      $self->lastcmd($libSQL::cmd);

      if ($libSQL::err != 0) {
         $self->log('warning',"load_raw_graph_data::[WARN] Error en Insert de $table (RV=undef)");
      }
   }

	if ($mode eq 'COUNTER') {
		my @sdata=values(%$SCRATCH);

#print Dumper(\@sdata);

		$self->store_graph_data_scratch($dbh,$table_scratch,\@sdata);
$self->log('warning',"load_raw_graph_data::[DEBUG] Actualizo $table_scratch (RV=undef)");

	}

   $self->log('debug',"load_raw_graph_data:: TOTALES (INSERT=$c2|UPDATE=$c1) ($table) ");
}

#----------------------------------------------------------------------------
# Funcion: get_size_of_tables
# Descripcion:
#----------------------------------------------------------------------------
sub get_size_of_tables {
my ($self, $dbh, $top) =@_;

	if (! defined $top) { $top=20; }

   my $sql='SELECT table_schema as `DB`, table_name AS `Table`, round(((data_length + index_length) / 1024 / 1024), 2) `MB`  FROM information_schema.TABLES  ORDER BY (data_length + index_length) DESC';
   my $rres=$self->get_from_db_cmd($dbh,$sql,'');

   my $i=0;
   my %res=();
   foreach my $l (@$rres) {
      my $key = join('.', sprintf("%03d",$i), $l->[0], $l->[1]);
      $res{$key} = {'db'=>$l->[0], 'table'=>$l->[1], 'size'=>$l->[2]};
      if ($i<$top) {
         $self->log('info',"get_size_of_tables: $l->[2] MB >> $l->[0].$l->[1]");
      }
      $i+=1;
   }
   return \%res;

}

#----------------------------------------------------------------------------
# Funcion: limit_log_data
# Descripcion:
#----------------------------------------------------------------------------
sub limit_log_data {
my ($self, $dbh, $max_number) =@_;

   my $sql='SHOW tables LIKE "log%"';
   my $rres=$self->get_from_db_cmd($dbh,$sql,'');

   if ((! defined $max_number) || ($max_number=~/\d+/)) { $max_number=500000; }

   foreach my $l (@$rres) {

      my $table = $l->[0];
      $self->log('info',"MANTENIMIENTO DE DATOS: $table");
      $self->limit_table_in_lines($dbh, $table, 'id_log', $max_number, 'LOGS');
   }

}

#----------------------------------------------------------------------------
# Funcion: limit_table_in_lines
# Descripcion:
#----------------------------------------------------------------------------
sub limit_table_in_lines {
my ($self, $dbh, $table, $table_id, $max_lines, $text_item) =@_;

   my $rres=sqlSelectAll($dbh,$table_id,$table,'',"order by $table_id  desc limit $max_lines,1");
	my $border_id = (exists $rres->[0][0]) ? $rres->[0][0] : 0;
	
   $self->error($libSQL::err);
   $self->errorstr($libSQL::errstr);
   $self->lastcmd($libSQL::cmd);
	if ($libSQL::err) {
		$self->log('warning',"**DB-ERROR** [$libSQL::err] $libSQL::errstr ($libSQL::cmd)");
	}

  	my $rows=sqlDelete($dbh, $table, "$table_id<$border_id");

  	$self->error($libSQL::err);
  	$self->errorstr($libSQL::errstr);
  	$self->lastcmd($libSQL::cmd);

   my $rc=$libSQL::err;
   my $rcstr=$libSQL::errstr;

   if (! $rc) { $rcstr="Se borran $text_item ($rows lineas)";}
   $self->log_qactions($dbh, {'descr'=>"MANTENIMIENTO DE DATOS: $text_item Eliminados $rows elementos" , 'rc'=>$rc  , 'rcstr'=>$rcstr, 'atype'=>ATYPE_DB_MANT_TABLE_LIMIT });
   $self->log('info',"MANTENIMIENTO DE DATOS: $text_item Eliminados $rows elementos");

}

#----------------------------------------------------------------------------
# Funcion: limit_table_in_days
# Descripcion:
#----------------------------------------------------------------------------
sub limit_table_in_days {
my ($self, $dbh, $table, $table_date, $max_days, $text_item) =@_;

   my $tlast=time()-(86400*$max_days);
   my $tdate=$self->time2date($tlast);

   my $rows=sqlDelete($dbh, $table, "$table_date<$tlast");
   $self->error($libSQL::err);
   $self->errorstr($libSQL::errstr);
   $self->lastcmd($libSQL::cmd);
   my $rc=$libSQL::err;
   my $rcstr=$libSQL::errstr;

   if (! $rc) { $rcstr="Se borran $text_item. Se mantienen desde $tdate";}
   $self->log_qactions($dbh, {'descr'=>"MANTENIMIENTO DE DATOS: $text_item Eliminados $rows elementos" , 'rc'=>$rc  , 'rcstr'=>$rcstr, 'atype'=>ATYPE_DB_MANT_TABLE_LIMIT });
   $self->log('info',"MANTENIMIENTO DE DATOS: $text_item Eliminados $rows elementos (date<$tlast) ($tdate)");
   #print "MANTENIMIENTO DE DATOS: $text_item Eliminados $rows elementos (date<$tlast) ($tdate)\n";

}

#----------------------------------------------------------------------------
# Funcion: limit_metric_files
# Descripcion:
# Determinadas metricas guardan datos asociados a las medidas obtenidas.
# Son del tipo:
#/store/data/scripts/0000000003/
#-rw-r--r-- 1 root root  12652 Oct 12 01:47 1476229500-e873f0-fcaab8-www.s30labs.com-.har.gz
#-rw-r--r-- 1 root root  91663 Oct 12 01:47 1476229500-e873f0-ddc579-www.s30labs.com-quienes-somos-datos-de-contacto-.jpeg
#-rw-r--r-- 1 root root  16954 Oct 12 01:47 1476229500-e873f0-ddc579-www.s30labs.com-quienes-somos-datos-de-contacto-.har.gz
#-rw-r--r-- 1 root root 149445 Oct 12 01:47 1476229500-e873f0-0299cc-www.s30labs.com-servicios-.jpeg
#-rw-r--r-- 1 root root  11778 Oct 12 01:47 1476229500-e873f0-0299cc-www.s30labs.com-servicios-.har.gz
#----------------------------------------------------------------------------
sub limit_metric_files {
my ($self, $max_size) =@_;

   my $base_dir='/store/data/scripts';
   if (! -d $base_dir) { return; }

   my @sizes=`du --max-depth=1 $base_dir`;
#cnm@cnm004:~$ du --max-depth=1 /store/data/scripts/
#3815132 /store/data/scripts/0000000006
#4278080 /store/data/scripts/0000000003
#8093216 /store/data/scripts/
   foreach my $l (@sizes) {
      my ($size,$dir) = split(/\s+/,$l);
		$size *= 1000;
      if ($size <= $max_size) { next; }
      if (! -d $dir) { next; }
		if ($dir eq $base_dir) { next; }

      opendir (DIR,$dir);
      my @file_info = sort readdir(DIR);
      closedir(DIR);

		my $n=0;
      foreach my $f (@file_info) {
			if ($f !~ /^\d+\-\S+/) { next; }
			my $fpath = $dir.'/'.$f;
         if ($size <= $max_size) { last; }
         my $sizef = -s $fpath;
         my $rc = unlink $fpath;
         $size -= $sizef;
			$n+=1;
         #print "size=$size  sizef=$sizef Borrado ($rc): $fpath\n";
         $self->log('debug',"limit_metric_files:: ($n) size=$size  sizef=$sizef Borrado ($rc): $fpath");
      }
		$self->log('info',"limit_metric_files:: Borrados $n files en $dir");
   }
}


#----------------------------------------------------------------------------
# create_app_temp_table
# Elimina de la BBDD los datos previamente obtenidos de una APP.
# Tablas logp_xxxxx (logp_333333001008_icg_from_db)
#----------------------------------------------------------------------------
sub create_app_temp_table  {
my ($self,$dbh,$app_id,$app_name)=@_;

#CREATE TEMPORARY TABLE tmp_logp_333333001020_idocs_03_errors_from_sap (`id_log` int(11) NOT NULL AUTO_INCREMENT, `hash` varchar(16) NOT NULL DEFAULT 'unk', `ts` int(11) NOT NULL, `line` text NOT NULL,   PRIMARY KEY (`id_log`), UNIQUE KEY `hash_idx` (`hash`));

	$app_name=~s/\-/_/g;

	my $table = 'logp_'.$app_id.'_'.$app_name.'_temp';
   my $fields_create='id_log int NOT NULL AUTO_INCREMENT, hash varchar(16) NOT NULL default "unk", ts int NOT NULL, line TEXT NOT NULL, PRIMARY KEY (id_log), UNIQUE KEY hash_idx (hash)';

   sqlCreate($dbh,$table,$fields_create,0);

   $self->error($libSQL::err);
   $self->errorstr($libSQL::errstr);
   $self->lastcmd($libSQL::cmd);
   if ($libSQL::err != 0) {
      $self->log('info',"create_app_temp_table:**ERROR** AL CREAR TABLA TEMP $table ($libSQL::err $libSQL::errstr) (CMD=$libSQL::cmd)");
   }
   else {
      $self->log('info',"create_app_temp_table:[INFO] CREADA TABLA TEMP $table ($libSQL::err $libSQL::errstr) (CMD=$libSQL::cmd)");
   }
}

#----------------------------------------------------------------------------
# clear_app_data
# Elimina de la BBDD los datos previamente obtenidos de una APP.
# Tablas logp_xxxxx (logp_333333001008_icg_from_db)
#----------------------------------------------------------------------------
sub clear_app_data  {
my ($self,$dbh,$logfile,$source)=@_;

   # ------------------------------------------------------
	#ej: logp_333333001020_idocs_03_errors_from_sap
	$logfile=~s/\-/_/g;
	my $table = 'logp_'.$source.'_'.$logfile;
	my $where = '';

	if (! defined $dbh) { return undef; }
   my $rres=sqlDelete($dbh, $table, $where);

	$self->log('info',"delete_from_dated_table::[DEBUG] $libSQL::cmd");
   if ($libSQL::err) {
      $self->manage_db_error($dbh,"clear_app_data");
	}
   return;

}

#----------------------------------------------------------------------------
# clear_app_data_buffer
# Elimina de la BBDD los datos antiguos en tablas definidas como buffer.
# El objetivo es controlar su crecimiento.
# Tablas logp_xxxxx (logp_333333001008_icg_from_db)
#----------------------------------------------------------------------------
sub clear_app_data_buffer  {
my ($self,$dbh,$logfile,$source,$offset)=@_;

   # ------------------------------------------------------
   #ej: logp_333333001020_idocs_03_errors_from_sap
   $logfile=~s/\-/_/g;
   my $table = 'logp_'.$source.'_'.$logfile;
	if ((!defined $offset) || ($offset !~ /^\d+$/) || ($offset<86400)) {
		$offset = 86400;
	}
	my $tdiff = time()-$offset;
   my $where = "ts<$tdiff";

   if (! defined $dbh) { return undef; }

   my $rres=sqlDelete($dbh, $table, $where);

   $self->log('debug',"delete_from_buffer_table::[DEBUG] $libSQL::cmd");
   if ($libSQL::err) {
      $self->manage_db_error($dbh,"clear_app_data_buffer");
   }
   return;

}

#----------------------------------------------------------------------------
# flush_app_data
# Mueve los datos de la tabla temporal de la app logp_xxxxx_temp a la tabla final logp_xxxx
#----------------------------------------------------------------------------
sub flush_app_data  {
my ($self,$dbh,$app_id,$app_name)=@_;

	$app_name=~s/\-/_/g;
   my $table1 = 'logp_'.$app_id.'_'.$app_name.'_temp';
   my $table2 = 'logp_'.$app_id.'_'.$app_name;

   $self->log('info',"flush_app_data:: FLUSH DATA $table1 -> $table2");

	#sp_table1_to_table2('logp_333333001020_idocs_03_errors_from_sap','kk');
   my $rv=sqlCmd($dbh,"CALL sp_table1_to_table2(\'$table1\',\'$table2\')");

   $self->error($libSQL::err);
   $self->errorstr($libSQL::errstr);
   $self->lastcmd($libSQL::cmd);
   if ($libSQL::err) {
      $self->manage_db_error($dbh,"flush_app_data");
   }
}

#----------------------------------------------------------------------------
# set_log_rx_lines
# Inserta en BBDD las lineas de log recibidas por syslogd
# En este caso el nombre de la tabla se obtiene a partir de la IP y el local utilizado
# Devuelve el nombre de la tabla y el numero de filas insertadas
#----------------------------------------------------------------------------
sub set_log_rx_lines  {
my ($self,$dbh,$ip,$id_dev,$logfile,$source,$lines)=@_;

   # ------------------------------------------------------
   # logr_010002254223_syslog
   my @o = split(/\./,$ip);
   my @o3 = map { sprintf("%03d",$_) } @o;

	$logfile=~s/\-/_/g;
	my $prefix = ($source eq 'syslog') ? 'logr' : 'logp';
   my $table = $prefix.'_'.join ('',@o3).'_'.$logfile;
	# En el caso de las apps source es la app_id que se usa papra identificar la tabla.
	if ($source ne 'syslog') {
		$table = $prefix.'_'.$source.'_'.$logfile;
	}

	my $rv=0;	
	my $cnt_lines=0;
   foreach my $l (@$lines) {
      my %h = ();
      $h{'line'} = $l->{'line'};
      $h{'ts'}=$l->{'ts'};

		if ((exists $l->{'md5'}) && ($l->{'md5'}=~/\w{16}/)) {
			$h{'hash'} = $l->{'md5'};

      	$rv=sqlInsertUpdate4x($dbh,$table,\%h,\%h);
	      $self->error($libSQL::err);
   	   $self->errorstr($libSQL::errstr);
      	$self->lastcmd($libSQL::cmd);

$libSQL::cmd=~ s/\n/ /g;
$self->log('info',"*****DEBUG*****$libSQL::cmd******");

		}
		else {
	      my $k = md5_hex(encode_utf8($l->{'line'}));
   	   $h{'hash'} = substr $k,0,16;

	      $rv=sqlInsert($dbh,$table,\%h);
   	   $self->error($libSQL::err);
      	$self->errorstr($libSQL::errstr);
      	$self->lastcmd($libSQL::cmd);

		}

      #------------------------------------------------------------------------
      #my $rv=sqlInsert($dbh,$table,\%h);
      #$self->error($libSQL::err);
      #$self->errorstr($libSQL::errstr);
      #$self->lastcmd($libSQL::cmd);

      #Si no existe la tabla (1146), se crea
      if ($libSQL::err == 1146) {

         # id_dev,id_credential,logfile,tabname,todb,status,parser
         # todb indica si se recibe o es log_pull
         #----------------------------------------------------------------------------
         my %d=('id_dev'=>$id_dev,'id_credential'=>0,'logfile'=>$logfile,'tabname'=>$table,'todb'=>1,'status'=>0,'app_id'=>$source);
         if ($source ne 'syslog') { $d{'id_credential'}=1; }

         $self->init_device2log($dbh,\%d);
         $self->error($libSQL::err);
         $self->errorstr($libSQL::errstr);
         $self->lastcmd($libSQL::cmd);

         my $rv = $self->create_log_table($dbh,$table,$ip);
         if ($rv != 0) {
            $self->error($libSQL::err);
            $self->errorstr($libSQL::errstr);
            $self->lastcmd($libSQL::cmd);
            last;
         }

         $rv=sqlInsert($dbh,$table,\%h);
         $self->error($libSQL::err);
         $self->errorstr($libSQL::errstr);
         $self->lastcmd($libSQL::cmd);

			if ($libSQL::err == 0) { $cnt_lines++; }

#			# id_dev,id_credential,logfile,tabname,todb,status,parser
#			# todb indica si se recibe o es log_pull
#			#----------------------------------------------------------------------------
#			my %d=('id_dev'=>$id_dev,'id_credential'=>0,'logfile'=>$logfile,'tabname'=>$table,'todb'=>1,'status'=>0,'app_id'=>$source);
#			if ($source ne 'syslog') { $d{'id_credential'}=1; }
#
#			$self->init_device2log($dbh,\%d);
#   	   $self->error($libSQL::err);
#      	$self->errorstr($libSQL::errstr);
#	      $self->lastcmd($libSQL::cmd);

		}
      elsif ($libSQL::err == 1062) {
         $self->log('info',"NO inserto linea de log. Ya existe en BBDD.");
      }
      elsif ($libSQL::err > 0) {
         $self->error($libSQL::err);
         $self->errorstr($libSQL::errstr);
         $self->lastcmd($libSQL::cmd);
         $self->log('info',"DB ERR [$libSQL::err] $libSQL::errstr ($libSQL::cmd)");
      }
		else { $cnt_lines++; }

   }

   return ($table,$cnt_lines);
}


#----------------------------------------------------------------------------
# set_log_rx_lines_bulk
#----------------------------------------------------------------------------
# $lines -> [
#					{'ts'=>$t, 'line'=>$MSG{'source_line'}, 'md5'=>$MSG{'md5'}}
#					...
#				]
#----------------------------------------------------------------------------
sub set_log_rx_lines_bulk  {
my ($self,$dbh,$ip,$id_dev,$logfile,$source,$lines)=@_;

   # ------------------------------------------------------
   # logr_010002254223_syslog
   my @o = split(/\./,$ip);
   my @o3 = map { sprintf("%03d",$_) } @o;

   $logfile=~s/\-/_/g;
   my $prefix = ($source eq 'syslog') ? 'logr' : 'logp';
   my $table = $prefix.'_'.join ('',@o3).'_'.$logfile;
   # En el caso de las apps source es la app_id que se usa papra identificar la tabla.
   if ($source ne 'syslog') {
      $table = $prefix.'_'.$source.'_'.$logfile;
   }


	my $sql="INSERT INTO $table (ts,line,hash) VALUES (?,?,?) ON DUPLICATE KEY UPDATE ts=?, line=?, hash=?\n";
	my @dblines=(); #[ [ts,line,hash], [ts,line,hash] ... ]
   foreach my $l (@$lines) {
		my $md5='';
      if ((exists $l->{'hash'}) && ($l->{'hash'}=~/\w{16}/)) {
         $md5 = $l->{'hash'};
		}
		else {
         $md5 = md5_hex(encode_utf8($l->{'line'}));
			$md5 = substr $md5,0,16;
		}
		push @dblines, [$l->{'ts'}, $l->{'line'}, $md5, $l->{'ts'}, $l->{'line'}, $md5];

		#$self->log('info',"set_log_rx_lines_bulk: [$table] LINE $l->{'ts'}, $l->{'line'}, $md5");

	}
	my $cnt_lines=scalar(@dblines);
	
	my $rv=sqlCmd_fast($dbh,\@dblines,$sql);
   $self->error($libSQL::err);
   $self->errorstr($libSQL::errstr);
   $self->lastcmd($libSQL::cmd);

   #Si no existe la tabla (1146), se crea
   if ($libSQL::err == 1146) {

   	# id_dev,id_credential,logfile,tabname,todb,status,parser
      # todb indica si se recibe o es log_pull
      #----------------------------------------------------------------------------
      my %d=('id_dev'=>$id_dev,'id_credential'=>0,'logfile'=>$logfile,'tabname'=>$table,'todb'=>1,'status'=>0,'app_id'=>$source);
      if ($source ne 'syslog') { $d{'id_credential'}=1; }

      $self->init_device2log($dbh,\%d);
      $self->error($libSQL::err);
      $self->errorstr($libSQL::errstr);
      $self->lastcmd($libSQL::cmd);

      my $rv = $self->create_log_table($dbh,$table,$ip);
      if ($rv != 0) {
         $self->error($libSQL::err);
         $self->errorstr($libSQL::errstr);
         $self->lastcmd($libSQL::cmd);
         last;
      }

	   $rv=sqlCmd_fast($dbh,\@dblines,$sql);
   	$self->error($libSQL::err);
   	$self->errorstr($libSQL::errstr);
   	$self->lastcmd($libSQL::cmd);

	}

   if ($libSQL::err != 0) {
      $self->log('info',"set_log_rx_lines_bulk:**ERROR** ($libSQL::err $libSQL::errstr) (CMD=$libSQL::cmd) cnt_lines=$cnt_lines");
   }
   else {
      $self->log('debug',"set_log_rx_lines_bulk:[INFO] ($libSQL::err $libSQL::errstr) (CMD=$libSQL::cmd) cnt_lines=$cnt_lines");
   }


	return ($table,$cnt_lines);
}

#----------------------------------------------------------------------------
# set_log_pull_lines
# Inserta las lineas de log obtenidas mediante log_pull
# El nombre de la tabla es un parametro de la funcion (se obtiene de la tabla device2log)
sub set_log_pull_lines  {
my ($self,$dbh,$ip,$logfile,$table,$lines)=@_;

   # ------------------------------------------------------
   # logp_ip_logfile   >> logp_010001001001_varlogmessages
   # logp_010002254223_varlogapacheerrorlog
#   my @o = split(/\./,$ip);
#   my @o3 = map { sprintf("%03d",$_) } @o;
#   $logfile =~s/\///g;
#   $logfile =~s/\.//g;
#   $logfile =~s/\s//g;
#   my $table = 'logp_'.join ('',@o3).'_'.$logfile;

	foreach my $l (@$lines) {
		my %h = ();
		$h{'line'} = $l->{'line'};
		$h{'ts'}=$l->{'ts'};
		my $k = md5_hex(encode_utf8($l->{'line'}));
		$h{'hash'} = substr $k,0,16;

   	#------------------------------------------------------------------------
   	my $rv=sqlInsert($dbh,$table,\%h);
	   $self->error($libSQL::err);
   	$self->errorstr($libSQL::errstr);
   	$self->lastcmd($libSQL::cmd);

		#Si no existe la tabla, se crea
		if ($libSQL::err == 1146) {
			my $rv = $self->create_log_table($dbh,$table,$ip);
			if ($rv != 0) {
		      $self->error($libSQL::err);
      		$self->errorstr($libSQL::errstr);
      		$self->lastcmd($libSQL::cmd);
				last;
			}	

	      $rv=sqlInsert($dbh,$table,\%h);
   	   $self->error($libSQL::err);
      	$self->errorstr($libSQL::errstr);
      	$self->lastcmd($libSQL::cmd);
		}
	}
	
	return $table;
}

#----------------------------------------------------------------------------
sub create_log_table  {
my ($self,$dbh,$table,$ip)=@_;

   # ------------------------------------------------------
   my $fields_create='id_log int NOT NULL AUTO_INCREMENT, hash varchar(16) NOT NULL default "unk", ts int NOT NULL, line TEXT NOT NULL, PRIMARY KEY (id_log), UNIQUE KEY hash_idx (hash)';

   # ------------------------------------------------------
   # apps with flush mode ==> Insert in logp_xxxxx_temp table
   # but logp_xxxxx table must be created.
	my $table_no_temp=$table;
   if ($table=~/^(\S+?)_temp$/) {
      $table_no_temp=$1;
      sqlCreate($dbh,$table_no_temp,$fields_create);
      $self->error($libSQL::err);
      $self->errorstr($libSQL::errstr);
      $self->lastcmd($libSQL::cmd);
      if ($libSQL::err != 0) {
         $self->log('info',"create_log_table:**ERROR** AL CREAR TABLA $table_no_temp ($libSQL::err $libSQL::errstr) (CMD=$libSQL::cmd)");
      }
      else {
         $self->log('info',"create_log_table:[INFO] CREADA TABLA $table_no_temp ($libSQL::err $libSQL::errstr) (CMD=$libSQL::cmd)");
      }
   }

   # ------------------------------------------------------
   sqlCreate($dbh,$table,$fields_create);
   $self->error($libSQL::err);
   $self->errorstr($libSQL::errstr);
   $self->lastcmd($libSQL::cmd);
	if ($libSQL::err != 0) {
		$self->log('info',"create_log_table:**ERROR** AL CREAR TABLA $table ($libSQL::err $libSQL::errstr) (CMD=$libSQL::cmd)");
	}
	else {
   	$self->log('info',"create_log_table:[INFO] CREADA TABLA $table ($libSQL::err $libSQL::errstr) (CMD=$libSQL::cmd)");
	}


	# Se crea la vista asociada
   my $rres=sqlSelectAll($dbh,'name',$TAB_DEVICES_NAME,"ip='$ip'");
   my $name = $rres->[0][0];

	$rres=sqlSelectAll($dbh,'logfile,id_device2log,id_dev','device2log',"tabname='$table_no_temp'");
	my $logfile = $rres->[0][0];
	my $id_device2log = $rres->[0][1];
	my $id_dev = $rres->[0][2];


	my $vtable = 'v'.$table;
	my $select="SELECT id_log,hash,ts,line,'$logfile' as logfile,$id_device2log as id_device2log,'$name' as name,$id_dev as id_dev FROM $table";
	sqlCreateView($dbh,$vtable,$select);
   if ($libSQL::err != 0) {
      $self->log('info',"create_log_table:**ERROR** AL CREAR VISTA $vtable ($libSQL::err $libSQL::errstr) (CMD=$libSQL::cmd)");
   }
   else {
      $self->log('info',"create_log_table:[INFO] CREADA VISTA $vtable ($libSQL::err $libSQL::errstr) (CMD=$libSQL::cmd)");
   }

   # ------------------------------------------------------
   # apps with flush mode ==> Insert in logp_xxxxx_temp table
   # but logp_xxxxx table must be created.
	my $vtable_no_temp = $vtable;
   if ($vtable=~/^(\S+?)_temp$/) {
		$vtable_no_temp=$1;
		my $select_no_temp="SELECT id_log,hash,ts,line,'$logfile' as logfile,$id_device2log as id_device2log,'$name' as name,$id_dev as id_dev FROM $table_no_temp";
	   sqlCreateView($dbh,$vtable_no_temp,$select_no_temp);
   	if ($libSQL::err != 0) {
      	$self->log('info',"create_log_table:**ERROR** AL CREAR VISTA $vtable_no_temp ($libSQL::err $libSQL::errstr) (CMD=$libSQL::cmd)");
   	}
   	else {
      	$self->log('info',"create_log_table:[INFO] CREADA VISTA $vtable_no_temp ($libSQL::err $libSQL::errstr) (CMD=$libSQL::cmd)");
   	}
	}

	return $libSQL::err;
}


#----------------------------------------------------------------------------
sub rotate_log_pull_lines  {
my ($self,$dbh,$ip,$logfile)=@_;

	# Calculo un timestamp de hace 24h
	my $ts=time-24*3600;	
   my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($ts);
   $year+=1900;
   $mon+=1;
	my $date_yesterday=$year.'-'.sprintf("%02d",$mon).'-'.sprintf("%02d",$mday);

   # ------------------------------------------------------
   # logp_ip_logfile   >> logp_010001001001_varlogmessages
   # logp_010002254223_varlogapacheerrorlog
   my @o = split(/\./,$ip);
   my @o3 = map { sprintf("%03d",$_) } @o;
   $logfile =~s/\///g;
   $logfile =~s/\.//g;
   $logfile =~s/\s//g;
	my $table = 'logp_'.join ('',@o3).'_'.$logfile;

   # ------------------------------------------------------
   my $outfile = '/store/remote_logs/'.$table.'-'.$date_yesterday;
   if (-f $outfile) { unlink $outfile; }

   #------------------------------------------------------------------------
	my $sql = "SELECT line INTO OUTFILE '$outfile' FROM $table WHERE DATE(FROM_UNIXTIME(ts))='$date_yesterday' order by ts";
   my $rv=sqlCmd($dbh,$sql);
   $self->error($libSQL::err);
   $self->errorstr($libSQL::errstr);
   $self->lastcmd($libSQL::cmd);

	if ($libSQL::err) {
		$self->log('info',"rotate_log_pull_lines:[INFO] **ROTATE ERROR** ($libSQL::err $libSQL::errstr) (CMD=$libSQL::cmd)");
	}
	else {
      $self->log('info',"rotate_log_pull_lines:[INFO] ROTATE OK ($libSQL::err $libSQL::errstr) (CMD=$libSQL::cmd)");
   }

	# Para ser borrados desde interfaz
	if (-f $outfile) { `/bin/chown root:www-user $outfile`; }

   #------------------------------------------------------------------------
	# Si la escritura a oiutfile ha sido correcta se limpian los datos de la tabla
	# Tambien se rotan los ficheros

}


#----------------------------------------------------------------------------
sub clear_log_pull_lines  {
my ($self,$dbh,$ip,$logfile)=@_;

   # ------------------------------------------------------
   # logp_ip_logfile   >> logp_010001001001_varlogmessages
   # logp_010002254223_varlogapacheerrorlog
   my @o = split(/\./,$ip);
   my @o3 = map { sprintf("%03d",$_) } @o;
   $logfile =~s/\///g;
   $logfile =~s/\.//g;
   $logfile =~s/\s//g;
   my $table = 'logp_'.join ('',@o3).'_'.$logfile;

   #------------------------------------------------------------------------
   my $rv=sqlDrop($dbh,$table);
   $self->error($libSQL::err);
   $self->errorstr($libSQL::errstr);
   $self->lastcmd($libSQL::cmd);

   if ($libSQL::err) {
      $self->log('info',"clear_log_pull_lines:[INFO] **CLEAR ERROR** ($libSQL::err $libSQL::errstr) (CMD=$libSQL::cmd)");
   }
   else {
      $self->log('info',"clear_log_pull_lines:[INFO] CLEAR OK ($libSQL::err $libSQL::errstr) (CMD=$libSQL::cmd)");
   }

}


#----------------------------------------------------------------------------
# check_dyn_names
# 1 nombre -> N IPs
# 1 IP -> N nombres
#----------------------------------------------------------------------------
#outlook.office365.com.  37      IN      CNAME   outlook-tm.g.office365.com.
#outlook-tm.g.office365.com. 17  IN      CNAME   outlook.ha.office365.com.
#outlook.ha.office365.com. 41    IN      CNAME   outlook.ms-acdc.office.com.
#outlook.ms-acdc.office.com. 41  IN      CNAME   dub-efz.ms-acdc.office.com.
#dub-efz.ms-acdc.office.com. 41  IN      A       40.101.100.2
#dub-efz.ms-acdc.office.com. 41  IN      A       40.101.40.210
#dub-efz.ms-acdc.office.com. 41  IN      A       40.101.72.162
#dub-efz.ms-acdc.office.com. 41  IN      A       40.101.125.34
#-------------------------------------------------------------------------------------------
sub check_dyn_names {
my ($self,$dbh) = @_;

	my $file_dyn_names='/cfg/names.dyn';

	my $db_dyn_stored=$self->get_device($dbh,{'dyn'=>1},'id_dev,name,domain,ip');
	open (F,">$file_dyn_names");
	foreach my $x (@$db_dyn_stored) {
		my $n=$x->[1];
		if ($x->[2] ne '') { $n = join ('.', $x->[1], $x->[2]); }
      print F  "$n\n";
	}
	close F;

   my @lines = `/usr/bin/dig -f $file_dyn_names  +noall +answer`;
   my %vector=();
   my %cnames=();
	my %result=();
   foreach my $l (@lines) {
      chomp $l;
      #www.s30labs.com.        14070   IN      A       178.33.163.102
      #test-oauth2-provider.eu.cloudhub.io. 21 IN CNAME ch-prod-web-elbweb-xxxxxxxxx-570345098.eu-west-1.elb.amazonaws.com.
      if ($l=~/^(\S+)\.\s+\d+\s+IN\s+A\s+(\S+)$/) {
			my ($a,$b)=($1,$2);
			$b=~s/(\S+)\.$/$1/;
         $vector{$b}=$a;
         #$self->log('info',"check_dyn_names:: A>> $b---$a----");
      }
      elsif ($l=~/^(\S+)\.\s+\d+\s+IN\s+CNAME\s+(\S+)$/) {
         my ($a,$b)=($1,$2);
         $b=~s/(\S+)\.$/$1/;
         $cnames{$b}=$a;
         #$self->log('info',"check_dyn_names:: CNAME>>$b---$a----");
      }
   }

   #my $db_dyn_stored=$self->get_device($dbh,{'dyn'=>1},'id_dev,name,domain,ip');
   foreach my $x (@$db_dyn_stored) {
		my ($change,$new_ip) = (0,'');
      my $id_dev=$x->[0];
      my $ip=$x->[3];
      my $name=$x->[1];
      if ($x->[2] ne '') { $name = join ('.', $x->[1], $x->[2]); }
      #$self->log('info',"check_dyn_names:: BUSCO name=$name con ip=$ip");
      if (exists $vector{$ip}) {
         if ($vector{$ip} eq $name) { $change = 0; }
         else {
            my $n = $vector{$ip};
            while (exists $cnames{$n}) {
      #$self->log('info',"check_dyn_names:: ITEROa $cnames{$n} == $name");
               if ($cnames{$n} eq $name) { $change = 0; }
               $n = $cnames{$n};
            }
         }
      }
      else { 
			my %revcnames = reverse %cnames;
         my $n = $name;
         while (exists $revcnames{$n}) {
      #$self->log('info',"check_dyn_names:: ITEROb $revcnames{$n} == $name");
            if ($revcnames{$n} eq $name) { $change = 0; }
            $n = $revcnames{$n};
         }
			foreach my $curr_ip (sort keys %vector) {
      #$self->log('info',"check_dyn_names:: ITEROc $vector{$curr_ip} == $n");
				if ($vector{$curr_ip} eq $n) {
					$new_ip = $curr_ip;
					$change = 1;
					#$self->log('info',"check_dyn_names:: IN DB name=$n|ip=$curr_ip ok=$ok");
					last; # La primera IP nueva es valida
				}
			}
		}
		$result{$name}={'ip'=>$ip, 'new_ip'=>$new_ip, 'id_dev'=>$id_dev, 'change'=>$change};
      $self->log('info',"check_dyn_names:: IN DB name=$name|ip=$ip|new_ip=$new_ip change=$change");
   }

	return \%result;
}



#----------------------------------------------------------------------------
# Funcion: get_maintenance_calendars
# Descripcion: Returns a hash with the calendar files deined in a device custom field
#----------------------------------------------------------------------------
sub get_maintenance_calendars {
my ($self,$dbh,$params)=@_;

	my %calendar_files = ();
	my $custom_field = $params->{'custom_field'};
	my $rres = $self->get_from_db_cmd($dbh,"SELECT id FROM devices_custom_types WHERE descr = '$custom_field'");

	if (!defined $rres->[0][0]) { 
		$self->log('info',"custom_field $custom_field not found");
		return \%calendar_files;
	}

	my $field = 'columna'.$rres->[0][0];
	#$rres = $self->get_from_db_cmd($dbh,"SELECT d.id_dev,d.name,d.domain,c.columna2  FROM devices d, devices_custom_data c WHERE d.id_dev=c.id_dev AND c.columna2 !='-'");
	$rres = $self->get_from_db_cmd($dbh,"SELECT d.id_dev,d.name,d.domain,c.$field  FROM devices d, devices_custom_data c WHERE d.id_dev=c.id_dev AND c.$field !='-'");
	foreach my $r (@$rres) {
   	my $id_dev = $r->[0];
   	my $name = $r->[1];
   	if ($r->[2] ne '') { $name .= '.'.$r->[2]; }
   	my $file_path = join('/',$params->{'dir_base'},$r->[3]);

		$calendar_files{$id_dev} = {'name'=>$name, 'file'=>$file_path};
	}
	return \%calendar_files;

}


#----------------------------------------------------------------------------
# Funcion: get_from_db_cmd
# Descripcion:
#----------------------------------------------------------------------------
sub get_from_db_cmd {
my ($self,$dbh,$sql,$key)=@_;

   if (! defined $key) { $key=''; }
   my $rres=sqlSelectAllCmd($dbh,$sql,$key);
   $self->error($libSQL::err);
   $self->errorstr($libSQL::errstr);
   $self->lastcmd($libSQL::cmd);

   if ((! defined $rres) || ($libSQL::err)) {
      $self->log('info',"get_from_db_cmd: [INFO] **ERROR** ($libSQL::err $libSQL::errstr) (CMD=$libSQL::cmd)");
		$rres = [];
   }
   else {
      $self->log('debug',"get_from_db_cmd: [INFO] --OK-- ($libSQL::err $libSQL::errstr) (CMD=$libSQL::cmd)");
   }

   return $rres;

}


#----------------------------------------------------------------------------
# Funcion: get_from_db
# Descripcion: Select generico
#----------------------------------------------------------------------------
sub get_from_db {
my ($self,$dbh,$what,$table,$where, $other)=@_;

   if (! defined $dbh) { 
      $self->log('info',"get_from_db: [INFO] **ERROR** DBH UNDEF");
		return []; 
	}

	$libSQL::err=0;
	$libSQL::errstr='';

   my $rres=sqlSelectAll($dbh, $what, $table, $where, $other);

   $self->error($libSQL::err);
   $self->errorstr($libSQL::errstr);
   $self->lastcmd($libSQL::cmd);

   if ((! defined $rres) || ($libSQL::err)) {
      $self->manage_db_error($dbh,"get_from_db");
      return [];
   }

   return $rres;
}

#----------------------------------------------------------------------------
# Funcion: get_last_id
# Descripcion:
#----------------------------------------------------------------------------
sub get_last_id {
my ($self,$dbh,$table,$field)=@_;

	my $id = sqlLastInsertId($dbh,$table,$field);

	if (! defined $id) { 
		$self->log('warning',"get_last_id:: err=$libSQL::err ($libSQL::errstr)");
		$id=-1;
	}

   return $id;
}


#----------------------------------------------------------------------------
# Funcion: delete_from_db
# Descripcion: Delete generico
#----------------------------------------------------------------------------
sub delete_from_db {
my ($self,$dbh,$table,$where)=@_;

   if (! defined $dbh) { return undef; }
   my $rres=sqlDelete($dbh, $table, $where);

   $self->error($libSQL::err);
   $self->errorstr($libSQL::errstr);
   $self->lastcmd($libSQL::cmd);

   if ($libSQL::err) {
      #$self->log('warning',"delete_from_dated_table::[WARN] table=$table ($libSQL::errstr)");
		$self->manage_db_error($dbh,"delete_from_dated_table");
      return;
   }
   else { $self->log('debug',"delete_from_dated_table::[DEBUG] $libSQL::cmd"); }

   return $rres;	#affected rows
}

#----------------------------------------------------------------------------
# Funcion: update_db
# Descripcion: Update generico
#----------------------------------------------------------------------------
sub update_db {
my ($self,$dbh,$table,$data,$where)=@_;

   if (! defined $dbh) { return undef; }
   my $rres=sqlUpdate($dbh, $table, $data, $where);

   $self->error($libSQL::err);
   $self->errorstr($libSQL::errstr);
   $self->lastcmd($libSQL::cmd);

   return $rres;
}


#----------------------------------------------------------------------------
# Funcion: insert_to_db
# Descripcion: Insert or Update generico
#----------------------------------------------------------------------------
sub insert_to_db {
my ($self,$dbh,$table,$data)=@_;
my $rres;

   if (! defined $dbh) { return undef; }

   #------------------------------------------------------------------------
	if (ref($data) ne "HASH") {
		# $data es del tipo: campo=valor,campo=valor.....
		my @d=split(/\,/,$data);
		my %tab=();
		foreach my $kv (@d) {
			my ($k,$v)=split(/\=/,$kv);
			$tab{$k}=$v;
		}
		$rres=sqlInsertUpdate4x($dbh,$table,\%tab,\%tab);
	}
	else {  $rres=sqlInsertUpdate4x($dbh,$table,$data,$data); }

   $self->error($libSQL::err);
   $self->errorstr($libSQL::errstr);
   $self->lastcmd($libSQL::cmd);

   if ($libSQL::err) {
      #$self->log('warning',"insert_to_db::[WARN] ERROR $libSQL::err  $libSQL::errstr ($libSQL::cmd)");
		$self->manage_db_error($dbh,"insert_to_db");
      return undef;
   }

	return $rres;

}

#----------------------------------------------------------------------------
# Funcion: db_cmd_fast
# Descripcion: Select generico
#----------------------------------------------------------------------------
sub db_cmd_fast {
my ($self,$dbh,$data,$sql)=@_;
my $rc=undef;

   $rc=sqlCmd_fast($dbh,$data,$sql);

   $self->error($libSQL::err);
   $self->errorstr($libSQL::errstr);
   $self->lastcmd($libSQL::cmd);

   if ($libSQL::err) {
      #$self->log('warning',"db_cmd_fast::[ERROR] $sql ($libSQL::err)");
		$self->manage_db_error($dbh,"db_cmd_fast");
      return undef;
   }

   return $rc;

}

#----------------------------------------------------------------------------
# Funcion: db_cmd
# Descripcion: Ejecuta comando generico, sin dataset
#----------------------------------------------------------------------------
sub db_cmd {
my ($self,$dbh,$sql)=@_;
my $rc=undef;

   $rc=sqlCmd($dbh,$sql);

   $self->error($libSQL::err);
   $self->errorstr($libSQL::errstr);
   $self->lastcmd($libSQL::cmd);

   if ($libSQL::err) {
      #$self->log('warning',"db_cmd::[ERROR] $sql ($libSQL::err)");
		$self->manage_db_error($dbh,"db_cmd");
      return undef;
   }

   return $rc;
}


#----------------------------------------------------------------------------
# Funcion: validate_params
# Descripcion: Valida parametros
#----------------------------------------------------------------------------
sub validate_params {
my ($self,$vparams, $data)=@_;
my %table=();

	foreach my $p (@$vparams) {

	   if (defined $data->{$p}) { $table{$p}=$data->{$p}; }
   	else {
      	$self->error(1);
      	$self->errorstr("No definido campo $p");
      	return undef;;
   	}
	}

	$self->table_data(\%table);
	return \%table;
}

#----------------------------------------------------------------------------
# Funcion: set_db_cs
# Descripcion:
#----------------------------------------------------------------------------
sub set_db_cs {
my ($self,$dbh,$cs)=@_;

   my $rc=sqlSetCS($dbh,$cs);

   $self->error($libSQL::err);
   $self->errorstr($libSQL::errstr);
   $self->lastcmd($libSQL::cmd);

   if ($libSQL::err) {
      #$self->log('warning',"set_db_cs::[ERROR] $libSQL::sql ($libSQL::err)");
		$self->manage_db_error($dbh,"set_db_cs");
      return undef;
   }


   return $rc;

}


#----------------------------------------------------------------------------
# Funcion: show_tables
# Descripcion:
#----------------------------------------------------------------------------
sub show_tables {
my ($self,$dbh,$table)=@_;


   if (! defined $dbh) { return []; }
   my $rres=sqlTableExists($dbh,$table);

   $self->error($libSQL::err);
   $self->errorstr($libSQL::errstr);
   $self->lastcmd($libSQL::cmd);

   if ($libSQL::err) {
      #$self->log('warning',"show_tables::[ERROR] $libSQL::sql ($libSQL::err)");
		$self->manage_db_error($dbh,"show_tables");
      return [];
   }

   return $rres;
}



#----------------------------------------------------------------------------
# Funcion: open_db
# Descripcion:
#----------------------------------------------------------------------------
sub open_db {
my ($self,$db)=@_;

	$libSQL::err=0;
	$libSQL::errstr='';

	#if (! defined $db) {	$db=\%DB; }
	if (! defined $db) {	$db=$self->db(); }
	my $dbh=sqlConnect($db);

	# Este parametro es vital si se quiere que al hacer forks no se cierren
	# las conexiones a la BBDD cuando terminan los hijos.
	#$dbh->{InactiveDestroy} = 1;

   if ($libSQL::err) {
      $self->manage_db_error($dbh,"open_db");
      return $dbh;
   }

   $self->error($libSQL::err);
   $self->errorstr($libSQL::errstr);

	return $dbh;

}

#----------------------------------------------------------------------------
# Funcion: fork_db
# Descripcion:
#----------------------------------------------------------------------------
sub fork_db {
my ($self,$dbh)=@_;

$libSQL::err=0;
$libSQL::errstr='';

	my $child_dbh = $dbh->clone();
   $dbh->{InactiveDestroy} = 1;
	return $child_dbh;
}

#----------------------------------------------------------------------------
# Funcion: close_db
# Descripcion:
#----------------------------------------------------------------------------
sub close_db {
my ($self,$dbh)=@_;

	my $rc=0;
	if ( (defined $dbh) && (ref($dbh) eq "DBI::db") ) { $rc=$dbh->disconnect(); }
	return $rc;
}

#----------------------------------------------------------------------------
# Funcion: show_vars
# Descripcion:
#----------------------------------------------------------------------------
sub show_vars {
my ($self,$dbh,$vars)=@_;

   if (! defined $dbh) { return []; }
   my $rres=sqlShowVars($dbh,$vars);
$self->log('warning',"show_vars::[ERROR] cmd=$libSQL::cmd ($libSQL::err)");

   $self->error($libSQL::err);
   $self->errorstr($libSQL::errstr);
   $self->lastcmd($libSQL::cmd);

   if ($libSQL::err) {
      #$self->log('warning',"show_vars::[ERROR] $libSQL::cmd ($libSQL::err)");
		$self->manage_db_error($dbh,"show_vars");
      return [];
   }

   return $rres;
}

#----------------------------------------------------------------------------
# Funcion: show_colummns
# Descripcion:
#----------------------------------------------------------------------------
sub show_colummns {
my ($self,$dbh,$table)=@_;

   if (! defined $dbh) { return []; }
   my $rres=sqlShowColumns($dbh,$table);
$self->log('warning',"show_vars::[ERROR] cmd=$libSQL::cmd ($libSQL::err)");

   $self->error($libSQL::err);
   $self->errorstr($libSQL::errstr);
   $self->lastcmd($libSQL::cmd);

   if ($libSQL::err) {
      #$self->log('warning',"show_vars::[ERROR] $libSQL::cmd ($libSQL::err)");
		$self->manage_db_error($dbh,"show_vars");
      return [];
   }

   return $rres;
}

#----------------------------------------------------------------------------
# Funcion: drop_databse
# Descripcion:
#----------------------------------------------------------------------------
sub drop_databse {
my ($self,$dbh, $database)=@_;

	my $rc=sqlDropDatabase($dbh,$database);

   $self->error($libSQL::err);
   $self->errorstr($libSQL::errstr);
   $self->lastcmd($libSQL::cmd);

   if ($libSQL::err) {
      #$self->log('warning',"drop_databse::[ERROR = $libSQL::err] $libSQL::errstr SQL=$libSQL::cmd");
		$self->manage_db_error($dbh,"drop_databse");
      return undef;
   }

	return $rc;
}

#----------------------------------------------------------------------------
# Funcion: check_table
# Descripcion:
#----------------------------------------------------------------------------
sub check_table {
my ($self,$dbh,$table)=@_;

   my $rv=sqlCmdRows($dbh,"CHECK TABLE $table");

   $self->error($libSQL::err);
   $self->errorstr($libSQL::errstr);
   $self->lastcmd($libSQL::cmd);
   if ($libSQL::err) {
      $self->manage_db_error($dbh,"check_table");
   }

#| Table      | Op      | Msg_type | Msg_text |
	return $rv;
}

#----------------------------------------------------------------------------
# Funcion: repair_table
# Descripcion:
#----------------------------------------------------------------------------
sub repair_table {
my ($self,$dbh,$table)=@_;

   my $rv=sqlCmdRows($dbh,"REPAIR TABLE $table");

   $self->error($libSQL::err);
   $self->errorstr($libSQL::errstr);
   $self->lastcmd($libSQL::cmd);
   if ($libSQL::err) {
      $self->manage_db_error($dbh,"repair_table");
   }

#| Table      | Op      | Msg_type | Msg_text |
   return $rv;
}

#----------------------------------------------------------------------------
# Funcion: delete_table
# Descripcion:
#----------------------------------------------------------------------------
sub delete_table {
my ($self,$dbh, $table)=@_;


	my $errors=0;
	my $TABLES=$self->show_tables($dbh,$table);
	if (! $libSQL::err) {
   	foreach my $t (@$TABLES) {
      	sqlDrop($dbh, $t->[0]);
		   $self->error($libSQL::err);
   		$self->errorstr($libSQL::errstr);
   		$self->lastcmd($libSQL::cmd);

			if ($libSQL::err) {
				#$self->log('warning',"delete_table::[ERROR = $libSQL::err] $libSQL::errstr SQL=$libSQL::cmd");
				$self->manage_db_error($dbh,"delete_table");
				$errors+=1;
			}
		}
	}
	else {
		$self->log('warning',"delete_table::[ERROR = $libSQL::err] $libSQL::errstr SQL=$libSQL::cmd");
      $errors+=1;
	}

	return $errors;
}


#----------------------------------------------------------------------------
# Funcion: manage_error
# Descripcion:
#----------------------------------------------------------------------------
sub manage_db_error {
my ($self,$dbh,$tag)=@_;

   my $err=$self->error();
   my $errstr=$self->errorstr();
   my $cmd=$self->lastcmd();

	$self->log('warning',"manage_db_error::[WARN] ERROR=$err ($errstr) EN $tag ($cmd)");

   #145
   #Table './onm/alerts' is marked as crashed and should be repaired
   if ($err == 145) {
      if ($errstr=~/Table.*?\/(\S+)\/(\S+)' is marked as crashed and should be repaired/) {
			my $table=$1.'.'.$2;
      	my $res = $self->repair_table($dbh,$table);
      	my $result=$res->[3];
      	$self->log('info',"manage_db_error::[$err] **REPAIR** TABLE: $table RESULT=$result");
		}
   }
	#2006
	#MySQL server has gone away
#	elsif ($err > 2000) {
#     	$self->log('info',"manage_db_error::[$err] **RECONNECT**");
#      $self->close_db($dbh);
#      my $dbh2=$self->open_db();
#      $self->dbh($dbh2);
#	}

}



1;
__END__

