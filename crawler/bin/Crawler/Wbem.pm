#####################################################################################################
# Fichero: Crawler::Wbem.pm 
# Revision: Ver $VERSION
# Descripción: Clase Crawler::Wbem
# Set Tab=3
#####################################################################################################
use Crawler;
package Crawler::Wbem;
@ISA=qw(Crawler);
$VERSION='1.00';
use strict;
use Digest::MD5 qw(md5_hex);
use Metrics::Base;
use ONMConfig;

#----------------------------------------------------------------------------
my %WBEM_CACHE=();

#----------------------------------------------------------------------------
my $ETXT='KEY-ERROR';

#----------------------------------------------------------------------------
use constant STAT_BAJA => 1;
use constant STAT_MANT => 2;
use constant STAT_ERASE => 3;

#----------------------------------------------------------------------------
my $WBEMCLI_PROG='/usr/local/bin/wbemcli';
my $WBEMCLI_OPTIONS=' -nl ei ';
my $WBEMCLI_OPTIONS_IID=' -nl ein ';
my $WBEMCLI_TIMEOUT=5;
#my $WMINAMESPACE='/root/cimv2';

#----------------------------------------------------------------------------
#----------------------------------------------------------------------------
#----------------------------------------------------------------------------
#----------------------------------------------------------------------------

#----------------------------------------------------------------------------
# Funcion: Constructor
# Descripcion: Crea un objeto del tipo Crawler::Wbem
#----------------------------------------------------------------------------
sub new {
my ($class,%arg) =@_;

	BEGIN {  $ENV{'MIBS'}='ALL'; }

   my $self=$class->SUPER::new(%arg);
   $self->{_cfg} = $arg{cfg} || '';
   $self->{_timeout} = $arg{timeout} || 2000000;  #Se mide en microsegundos.
   $self->{_retries} = $arg{retries} || 2;  
   $self->{_version1} = $arg{version1} || '3.23.54';
   $self->{_version2} = $arg{version2} || '1.0.40';

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

#------------------------------------------------------------------------------
sub clear_cache  {
my $self=shift;

   %WBEM_CACHE=();
}


#----------------------------------------------------------------------------
#----------------------------------------------------------------------------
#----------------------------------------------------------------------------
#----------------------------------------------------------------------------


#----------------------------------------------------------------------------
# do_task
#----------------------------------------------------------------------------
sub do_task  {
my ($self,$lapse,$range)=@_;
my @task=();
my $NM=0; 	#Numero de metricas a procesar
my $NU=0;	#Numero de metricas a con respuesta=U


   while (1) {

		$self->clear_cache();

		my $store=$self->store();
		my $dbh=$self->dbh();

		# Control de cambios --------------------------------------------------
		my $reload=$self->get_file_idx($range,\@task);
		if ($reload) {
			$self->log('info',"do_task::#RELOAD **reload $range**");
	      my $rv=$store->get_crawler_task_from_file($range,\@task);
   	   if (!defined $rv) {
				#En este caso hago la tarea que estuviera contenida en el vector @task
				$self->log('warning',"do_task::#RELOAD[WARN] Tarea no definida");
			}
		}
      $NM=scalar @task;
		$self->log('info',"do_task::[INFO] -R- wbem.$lapse|IDX=$range|NM=$NM");

      my $tnext=time+$lapse;

		$NU=0;
      foreach my $desc (@task) {

         my $task_name=$desc->{module};
			my $task_id=$desc->{host_ip}.'-'.$desc->{name};
			$self->task_id($task_id);

#DBG--
         #$self->log('debug',"do_task::[DEBUG] *** TAREA=$task_id ($task_name) CLASS=@{[$desc->{class}]} PROPERTY=@{[$desc->{property}]} GET_IID=@{[$desc->{get_iid}]}" );
#/DBG--

         #----------------------------------------------------
         my $idmetric=$desc->{idmetric};
         if (! defined $idmetric) {
            $self->log('info',"do_task::[WARN] desc SIN IDMETRIC @{[$desc->{name}]} $task_name >> @{[$desc->{host_ip}]} @{[$desc->{host_name}]}");
         }

         #----------------------------------------------------
			my ($rv,$ev)=$self->modules_supported($desc);
			if ((defined $rv->[0]) && ($rv->[0] eq 'U')) {  $NU+=1; 	}
      }

      #----------------------------------------------------
      if ($Crawler::TERMINATE == 1) {
         $self->log('info',"do_task::[INFO] ***SIGTERM*** Terminamos recibida signal ...");
         exit 0;
      }
      my $wait = $tnext - time;
      if ($wait < 0) {
			$self->log('warning',"do_task::[WARN] *S* wbem.$lapse|IDX=$range|NM=$NM|NU=$NU|WAIT=$wait");
      }
      else {

         $self->log('info',"do_task::[INFO] -W- wbem.$lapse|IDX=$range|NM=$NM|NU=$NU|WAIT=$wait");
         sleep $wait;
      }
      #----------------------------------------------------
      if ($Crawler::TERMINATE == 1) {
         $self->log('info',"do_task::[INFO] ***SIGTERM*** Terminamos recibida signal ...");
         exit 0;
      }

      #if ($descriptor->{once}) {exit;}

   }
}

#----------------------------------------------------------------------------
# Funcion: modules_supported 
#----------------------------------------------------------------------------
# Descripcion:
#	1.	mod_wbem_get
#		1.1 --> core_wbem_get + create/update_rrd + mod_alert
# OUT:
# 	$rv = Referencia a un ARRAY con los datos de la metrica.
#	$ev = Referencia a un ARRAY con los datos del evento.
# 
#----------------------------------------------------------------------------
sub modules_supported  {
my ($self,$desc)=@_;
my $rv=undef;
my $ev=undef;

	$self->event_data([]);
	$self->response('OK');
	my $module=$desc->{'module'};

   if ($module =~ /mod_wbem_get/i) { ($rv,$ev)=$self->mod_wbem_get($desc);}

   else {$self->log('warning',"modules_supported::[WARN] No definido modulo: $module"); }

	return ($rv,$ev);
}


#-------------------------------------------------------------------------------------------
# Funcion: chk_metric
#-------------------------------------------------------------------------------------------
# Descripcion:
#     Valida una determinada metrica WBEM, del tipo que sea (en modules_supported)
#     Valida un monitor aplicado sobre una metrica WBEM
#     Valida el caso especial de sin respuesta wbem (mon_wbem)
#
# IN:
#
#  1. $in es una ref a hash con los datos necesarios para identificar metrica+dispositivo.
#     Hay 2 opciones (mejor la a.):
#        a. $in->{'host_ip'} && $in->{'mname'}. Valida a partir de la ip y el nombre de la metrica en cuestion
#        b. $in->{'id_dev'} && $in->{'id_metric'}. Valida a partir del id del device y del id de la metrica en cuestion.
#     El resto de datos se obtienen de la tbla cfg_monitor_wbem
#
# OUT:
#     1. El parametro $results es una ref a un array pare guardar los resultados
#     2. El valor de retorno es 0->Sin alerta/1->Con alerta
#     3. El metodo event_data debe contener el evento que ha generado alerta para que notificationsd
#        acceda a dicha info.
#		4. El metodo severity contiene el valor de la severidad de la alerta si el retorno es 1.
#-------------------------------------------------------------------------------------------
sub chk_metric {
my ($self,$in,$results,$store)=@_;

#   my $store=$self->create_store();
#   my $dbh=$store->open_db();
#   $self->dbh($dbh);

	my $task_id=$self->task_id();
   if (! defined $store) {
      $store=$self->create_store();
      my $dbh=$store->open_db();
      $self->dbh($dbh);
		$store->dbh($dbh);
   }

   my $dbh=$store->dbh();
	$self->watch(0);

	#--------------------------------------------------------------------------------------
   my ($ip,$mname)=($in->{'host_ip'}, $in->{'mname'});
	#--------------------------------------------------------------------------------------
	if ( (! defined $ip) && (! defined $mname) ) {

	   if ( (defined $in->{'id_dev'}) && (defined $in->{'id_metric'}) ) {
   	   # Buscamos ip y mname y los metemos en in
      	my $rres=$store->get_from_db( $dbh, 'ip', 'devices', "id_dev=$in->{id_dev}");
	      $ip=$rres->[0][0];
   	   $rres=$store->get_from_db( $dbh, 'name', 'metrics', "id_metric=$in->{id_metric}");
      	$mname=$rres->[0][0];
   	}

   	if ( (! defined $ip) && (! defined $mname) ) {
      	# No podemos hacer el chequeo
      	$results= [ 'ERROR. NO HAY DATOS' ];
     		return;
		}
   }

   #--------------------------------------------------------------------------------------
   # Caso especial SIN RESPUESTA WBEM (mon_wbem)
   #--------------------------------------------------------------------------------------
   if ($mname eq 'mon_wbem') {
      my $rres1=$store->get_from_db( $dbh, 'd.wbem_user,d.wbem_pwd', 'devices d', "d.ip=\'$ip\'");

      my %desc1=();
      $desc1{'host_ip'}=$ip;
      $desc1{'wbem_user'}=$rres1->[0][0];
      $desc1{'wbem_pwd'}=$rres1->[0][1];
		my ($rc1,$rcstr1,$res1) = $self-> verify_wbem_data(\%desc1);

      my $data_out1='';
      if ($rc1 != 0) {
         $data_out1 = "sin respuesta wbem ($rcstr1)";
         $self->event_data([$data_out1]);
      }
      else { $data_out1="@$res1\n";    }
      push @$results, ['Resultado:', $data_out1];
      if ($rc1 != 0) { 
			$self->severity(1);
			return 1; 
		}
      else {  return 0;  }
	}


	#--------------------------------------------------------------------------------------
	# El parametro de entrada es mname (metrica instanciada) pero en la consulta de cfg_monitor_wbem necesitamos el subtype
	# Si cfg=1 (sin iids) => subtype = mname
	# Si cfg=2 (con iids) => subtype	= mname sin la info de iids
	#	Como la info de iids no se puede saar del mname, hay qhe buscarlo en la tabla metrics (o debe ser pasado como parametro)
   my $subtype=$mname;
   my $iid='ALL';
   if ($mname =~ /(.*?)-(\w+)$/) {
      $subtype=$1;
      $iid=$2;
   }

#print "IP=$ip  MNAME=$mname  IID=$iid";

	#--------------------------------------------------------------------------------------
	# Obtengo los parametros necesarios para poder validar la metrica solicitada. 
	# Los datos relevantes de la metrica se obtienen de cfg_monitor_wbem
	# Los del dispositivo de devices (datos de acceso)
	# a partir de $ip (clave en devices) y subtype (clave en cfg_monitor_wbem)
	# No interesa cruzar esta tabla con metricas porque al chequear una metrica no aplicada no obtendriamos los datos 
	# de configuracion de la metrica y no se podria chequear
   my $rres=$store->get_from_db( $dbh, 'c.class,c.property,c.descr,c.items,c.module,d.wbem_user,d.wbem_pwd,c.namespace,c.get_iid,c.cfg,c.severity,c.mode,c.mode,d.id_dev', 'cfg_monitor_wbem c, devices d', " d.ip=\'$ip\' and c.subtype=\'$subtype\'");

   my %desc=();
   $desc{'host_ip'}=$ip;
   $desc{'name'}=$mname;
   $desc{'class'}=$rres->[0][0];
   $desc{'property'}=$rres->[0][1];
   my $DESCR=$rres->[0][2];
   my $items=$rres->[0][3];
   $desc{'module'}=$rres->[0][4];
   $desc{'wbem_user'}=$rres->[0][5];
   $desc{'wbem_pwd'}=$rres->[0][6];
   $desc{'namespace'}=$rres->[0][7];
   $desc{'get_iid'}=$rres->[0][8];
	my $cfg=$rres->[0][9];
	my $severity=$rres->[0][10];
	my $mode=$rres->[0][11];
   my $id_dev=$rres->[0][12];

	my $rres1=$store->get_from_db( $dbh, 'm.iid,m.file', 'metrics m, devices d', "m.id_dev=d.id_dev and  d.ip=\'$ip\' and  m.name=\'$mname\'");
	$iid=$rres1->[0][0];
	my $file=$rres1->[0][1];

	if ($desc{'get_iid'}) {
		$DESCR.= " $iid";
		$desc{'iid'}=$iid;
	}
#	$desc{'iid'}=$iid;
	else { $desc{'iid'}='ALL'; }

#print "VALIDANDO [ip=$desc{host_ip} mname=$mname] [class=$desc{class} property=$desc{property} module=$desc{module}  wbem_user=$desc{wbem_user} wbem_pwd=$desc{wbem_pwd} IID=$desc{'iid'} ]\n";

   push @$results, ['Metrica:',$DESCR,''];
   push @$results, ['Valores monitorizados:', $items, ''];
#   push @$results, ['Parametros:', $desc{params}, ''];
   my ($rv,$ev)=$self->modules_supported(\%desc);
   if (! defined $rv) {
      $self->data_out(['U']);
      return 'U';
   }
   $self->data_out($rv);
   $self->event_data($ev);

#FML. REVISAR !!! (rc,rcstr ...)

   my  $event_data=$ev->[0];
   if (ref($rv) ne 'ARRAY') { $rv=['sin datos']; }
   if (ref($ev) ne 'ARRAY') { $ev=[]; }
	my $data_out="@$rv\n";
	if (scalar @$ev > 0) { $data_out .= "(@$ev)";  }
   push @$results, ['Resultado:', $data_out];


   #--------------------------------------------------------------------------------------
   # Hay que contemplar el caso de las metricas diferenciales (counter), porque el watch hay
   # que evaluarlo sobre la diferencia, no sobre el valor absoluto
   if (($mode eq 'COUNTER') && ($file)) {
      my $rvd=$store->fetch_rrd_last($file);
      if (!defined $rvd) {
         $self->log('warning',"chk_metric::[WARN] **$desc{host_ip}:$mname MODE=COUNTER RV=UNDEF F=$file**");
      }
#DBG--
      else { $self->log('debug',"chk_metric::[DEBUG] **$desc{host_ip}:$mname MODE=COUNTER [@$rvd] F=$file**"); }
#/DBG--
      push @$results, ['Datos diferenciales:', "@$rvd"];
      #Para evaluar el watch
      $rv=$rvd;
   }


   #--------------------------------------------------------------------------------------
   # Miro si es necesario chequear un monitor asociado a dicha metrica. Solo en el caso en que:
   #  1. La metrica tenga monitor asociado (en alert_type)
   #  2. El monitor este asociado al dispositivo que se esta chequeando
   my $watch=$store->get_from_db( $dbh, 'a.cause,a.severity,a.expr,a.monitor', 'alert_type a, metrics m,devices d', "m.name=\'$mname\' and m.watch=a.monitor and m.id_dev=d.id_dev and d.ip=\'$ip\'");

   foreach my $w (@$watch) {

      my $cause=$w->[0];
      my $severity=$w->[1];
      my $expr=$w->[2];
      my $watch_name=$w->[3];
		my $rvj = join (', ',@$rv);
#DBG--
      $self->log('debug',"mod_alert::[DEBUG ID=$task_id] **TEST WATCH (2) => $watch_name => $cause|$expr|$severity**");
#/DBG--

      # Si el monitor es de analisis (STEP;v1+v2;5;TOUT) tengo que extraer la expresion.
      my ($fx,$expr_orig)=('',$expr);
      if ($expr=~/\s*;\s*/) {
         my @d = split (/\s*;\s*/, $expr);
         $expr=$d[1];
         $fx=$d[0];
      }

      my ($condition,$lval,$oper,$rval)=$self->watch_eval($expr,$rv,$file);
		push @$results, ['Monitor:', "$cause ($expr_orig) ($lval $oper $rval)",''];
		if (($condition) && (! $fx)) {
         #print "ALERTA POR MONITOR: $cause $expr (@$rv)\n";
         push @$results, ['Resultado:',"**ALERTA** ($lval $oper $rval)",''];
			my $ev="($rvj) **ALERTA ($expr) ($lval $oper $rval)**";
         $self->event_data([$ev]);
			$self->severity($severity);
			$self->watch($watch_name);
			$self->log('debug',"chk_metric::[DEBUG] ALERTA POR MONITOR: $cause $expr (@$rv) EV=$ev ");
			return 1;
      }
      else { 
         if (! $fx) {   push @$results, ['Resultado Monitor:',"($rvj)",''];  }
         else { push @$results, ['Resultado Monitor:',"($rvj) **NO SE HA VERIFICADO LA FUNCION $fx**",''];  }
			return 0;
		}
   }

	return 0;
}


#----------------------------------------------------------------------------
#. Funcion: core_wbem_get
# Descripcion: 
#	Funcion de base para obtener los valores de los atributos WBEM de la siguiente forma:
#	1. Obtiene todos los datos de la clase y los almacena por instancias
#	2. Parsea la/s propieda/des solicitadas por instancias. Si la metrica no tiene 
#		instancias (cfg=1) la instancia en el hash es 'ALL'.
#
#  Devuelve una referencia a un array con dichos valores
# 	IN: $desc >>>> referencia a hash con los datos necesarios
#		$desc->{'get_iid'} : 1 -> Tiene iids, 0 -> No tiene iids
#		$desc->{'iid'} : Contiene el /los iids especificados por el usuario.
#
#	OUT:
#
#	Devuelve una referencia a un array ($values) con los valores obtenidos.
#  Si hay algun error devuelve U en el array
#  En los metodos $self->err_str() y $self->err_num() almacena el codigo
#  y el mensaje de error obtenido.
#  Si todo ha sido correcto err_num=0 y err_str=OK
#
# wbemcli  ei 'http://adm:adm1234@10.2.84.161:5988/root/cimv2:Win32_PerfFormattedData_PerfOS_Memory'
#----------------------------------------------------------------------------
sub core_wbem_get  {
my ($self,$desc)=@_;

	my $task_id=$self->task_id();
   $self->err_str('[OK]');
   $self->err_num(0);

	my $iid='ALL';
	my @all_iids=();
   my @o=split(/\|/,$desc->{'property'});
   my @values=();

   #-------------------------------------------------------------------
	# Lo primero es comprobar si ya he obtenido todos los valores de la clase 
	# y el dispositivo en cuestion.
	# ej: 1.1.1.1.Win32_PerfFormattedData_PerfOS_Memory.propiedad-instancia
   #-------------------------------------------------------------------
   my $key = join ('.', $desc->{'host_ip'},$desc->{'class'});
	
   if ($WBEM_CACHE{$key}) {
#DBG--
      $self->log('debug',"core_wbem_get::[DEBUG ID=$task_id] SICACHE class=$desc->{class} prop=$desc->{property} VAL=$WBEM_CACHE{$key} (KEY=$key)**");
#/DBG--
   }
	
	else {

#DBG--
      $self->log('debug',"core_wbem_get::[DEBUG ID=$task_id] NOCACHE class=$desc->{class} prop=$desc->{property} (KEY=$key)");
#/DBG--

      $SIG{ALRM} = sub { die "timeout" };
		$SIG{CHLD} = 'IGNORE';


		my @res=();
		my $cmd=$self->_wbem_cmd($desc,'instances');

      eval {
         alarm($WBEMCLI_TIMEOUT);
			@res=`$cmd 2>&1`;
         alarm(0);
      };

      if ($@) { 
			my $errstr="[ERROR: Timeout]";
		   $self->err_str($errstr);
   		$self->err_num(1);
         $self->event_data(["ERROR: $errstr"]);
         $self->response('NOWBEM'); 
         foreach my $prop (@o) { push @values, 'U'; }
         return \@values;
		}

#DBG--
      $self->log('debug',"core_wbem_get::[DEBUG ID=$task_id] CMD=$cmd");
#/DBG--

		# Lo primero es revisar si ha funcionado. Los errores los devuelve por STDOUT y son de la forma:
		# *
		# * /usr/local/bin/wbemcli: Cim: (2) CIM_ERR_ACCESS_DENIED: Access to a CIM resource was not available to the client: "LogonUser()" 
		# *
		if ($res[1] =~ /$WBEMCLI_PROG\:\s*(.+)$/) { 
			my $errstr=$1;
			$self->event_data(["ERROR: $errstr"]);
         $self->err_str($errstr);
         $self->err_num(1);
			# * wbemcli: Http Exception: couldn't connect to server
			if ($errstr =~ /Http Exception/) { $self->response('NOWBEM'); }
			else { $self->response('EWBEM'); }

#DBG--
my $kk=$self->event_data();
my $ff=$kk->[0];
$self->log('debug',"core_wbem_get::[DEBUG ID=$task_id] ****FML*** EV=$ff **");
#/DBG--

			foreach my $prop (@o) { push @values, 'U'; }
			return \@values;
		}



		$self->response('OK');
		# Almaceno los datos en la cache
      # get_iid=0 ==> $WBEM_CACHE{ip.class}->{'ALL'}->{property}=value
      # get_iid=1 ==> $WBEM_CACHE{ip.class}->{iid}->{property}=value
		my $c=$desc->{'class'};
		foreach my $l (@res) {
			
			#fml if ($desc->{'get_iid'} == 1) {
			chomp $l;	
			if ($desc->{'get_iid'}) {

				#if ( $l =~ /$c\.Name=(".*?")/ ) {
				#	$iid=$1;
				#	push @all_iids,$iid;
				#	next;
				#}
				if (! $l) {next;}
            my $iid1=$self->is_wbem_iid($l);
            if (defined $iid1) { 
					$iid=$iid1;
					$self->log('debug',"core_wbem_get::[DEBUG ID=$task_id] **FML** iENCONTRADO IID=$iid");
               push @all_iids,$iid;
					next;
				}
	         my ($property,$value)=split('=',$l);
				$self->log('debug',"core_wbem_get::[DEBUG ID=$task_id] **FML** LINEA1=$l PROP=$property V=$value");
   	      if (! defined $value ) { next; }
      	   $property=~s/^\-(.*)/$1/;

#Parche exchange
if ($value =~ /TRUE/) {$value=1; }
elsif  ($value =~ /OK/) {$value=1; }
elsif  ($value =~ /FALSE/) {$value=0; }
elsif  ($value !~ /^\d+$/) {$value=0; }

         	$value=~s/\s*(\d+)\s*/$1/;
         	$WBEM_CACHE{$key}->{$iid}->{$property}=$value;
				$self->log('debug',"core_wbem_get::[DEBUG ID=$task_id] **FML** METO EN CACHE VAL=$value K=$key|IID=$iid|PROP=$property)");
			}
			else {
            if ( $l =~ /$c/ ) { next; }
			

	         my ($property,$value)=split('=',$l);
   	      if (! defined $value ) { next; }
      	   $property=~s/^-(.*)/$1/;

#Parche exchange
if ($value =~ /TRUE/) {$value=1; }
elsif  ($value =~ /OK/) {$value=1; }
elsif  ($value =~ /FALSE/) {$value=0; }
elsif  ($value !~ /^\d+$/) {$value=0; }

         	$value=~s/\s*(\d+)\s*/$1/;
         	$WBEM_CACHE{$key}->{$iid}->{$property}=$value;
				$self->log('debug',"core_wbem_get::[DEBUG ID=$task_id] **FML** METO EN CACHE VAL=$value K=$key|IID=$iid|PROP=$property)");

			}
		}
	}


   #-------------------------------------------------------------------
	# Si es una metrica con iids y no se ha especificado algun iid concreto obtengo el valor de
	# todos los iids.
	# Si es una metrica sin iids ==> iid='ALL'
	# IMPORTANTE !!! En wbem  los iids son strings ("C:","E:","_Total:" ...)
	#fml if ($desc->{'get_iid'} == 1) { 
	if ($desc->{'get_iid'}) { 
		if ($desc->{'iid'}) { @all_iids=($desc->{'iid'}); }
		#$iid = $desc->{'iid'}; 
	}
	else { @all_iids=('ALL'); } 

$self->log('debug',"core_wbem_get::[DEBUG ID=$task_id] **FML** ALL IIDS=@all_iids (KEY=$key)");

	# Recorro las instancias solicitadas
	foreach my $iid (@all_iids) {
$self->log('debug',"_core_wbem_get::[DEBUG ID=$task_id] **FML** RECORRO IID=$iid (KEY=$key)");

		# Recorro las propiedades
   	foreach my $prop (@o) {

			if (! exists $WBEM_CACHE{$key}->{$iid}) {
				$self->event_data(["Sin respuesta en instancia $iid"]);
				$self->log('info',"core_wbem_get::[DEBUG ID=$task_id] No existe IID=$iid (KEY=$key)");
				push @values,'U';
				next;
			}
			
			push @values,$WBEM_CACHE{$key}->{$iid}->{$prop};

my $kk=$WBEM_CACHE{$key}->{$iid}->{$prop};
$self->log('debug',"_core_wbem_get::[DEBUG ID=$task_id] **FML** RECORRO VAL=$kk (KEY=$key|IID=$iid|PROP=$prop)");


		}
	}

	return \@values;

}


#----------------------------------------------------------------------------
# Funcion: mod_wbem_get
#----------------------------------------------------------------------------
# Descripcion: 
# 	Modulo wbem standard
#
# wbemcli -nl ein 'http://adm:adm1234@10.2.84.161:5988/root/cimv2:Win32_PerfFormattedData_PerfDisk_LogicalDisk'
# 10.2.84.161:5988/root/cimv2:Win32_PerfFormattedData_PerfDisk_LogicalDisk.Name="C:"
# 10.2.84.161:5988/root/cimv2:Win32_PerfFormattedData_PerfDisk_LogicalDisk.Name="E:"
# 10.2.84.161:5988/root/cimv2:Win32_PerfFormattedData_PerfDisk_LogicalDisk.Name="_Total"
#
# wbemcli -nl ei 'http://adm:adm1234@10.2.84.161:5988/root/cimv2:Win32_PerfFormattedData_PerfDisk_LogicalDisk.Name="C:"'
#
#----------------------------------------------------------------------------
sub mod_wbem_get  {
my ($self,$desc)=@_;
my ($data,$t);


   my $task_id=$self->task_id();
	my $mode_flag=$self->mode_flag();

   #-------------------------------------------------------------------
	#http://adm:adm1234@10.2.84.161:5988/root/cimv2:Win32_PerfFormattedData_PerfDisk_LogicalDisk
	my $values=$self->core_wbem_get($desc);

	# Este chequeo es por precaucion, pero core_wbem_get no debe devolver nunca undef.
	if (!defined $values) {
		$self->log('warning',"mod_wbem_get::[WARN ID=$task_id] VAL=UNDEF class=$desc->{class} prop=$desc->{property} items=$desc->{items}"); 
	}
			
	else {
#DBG--
$self->log('debug',"mod_wbem_get::[DEBUG ID=$task_id] class=$desc->{class} prop=$desc->{property} VAL=@$values**");
#/DBG--

      # ext function ------------------------------------
		#if (defined $desc->{ext_function}) {
      #	no strict 'refs';
      #	$values=&{$desc->{ext_function}}($self,$values);
      #	use strict 'refs';
		#}


      # Caso de sin respuesta wbem
      #if ($values->[0] eq 'NOWBEM') { return ['NOSNMP']; }

		# El event_data sera el proporcionado por core_wbem_get
		#$self->event_data("OK");
		my $items = scalar @$values;
   	$t=time;
   	$data=join(':',$t,@$values);

		if ( $mode_flag->{rrd} ) {

			# Almacenamiento RRD --------------------------
			#my $rrd=$desc->{file_path}.$desc->{file};
			my $rrd=$self->data_path().$desc->{file};
			my $store=$self->store();

	      if ($store) {
   	      my $mode=$desc->{mode};
      	   my $lapse=$desc->{lapse};
				my $type=$desc->{mtype};
	         if (! -e $rrd) { $store->create_rrd($rrd,$items,$mode,$lapse,$t,$type); }
   	      my $r = $store->update_rrd($rrd,$data);
      	   if ($r) {
         	   my $ru = unlink $rrd;
            	$self->log('info',"mod_wbem_get::[DEBUG ID=$task_id] Elimino $rrd  ($ru)");
	            $store->create_rrd($rrd,$items,$mode,$lapse,$t,$type);
   	         $store->update_rrd($rrd,$data);
      	   }
      	}
		}
	}

   # Control de alertas --------------------------
	my $ev=$self->event_data();
	if ($mode_flag->{alert}) {
		my $idmetric=$desc->{idmetric};
		my $monitor=$desc->{module}.'&&'.$desc->{class};
   	$self->mod_alert($monitor,$data,$desc,$ev);
	}

	return ($values,$ev);
}


#----------------------------------------------------------------------------
# Funcion: verify_wbem_data
#----------------------------------------------------------------------------
# Descripcion:
#  Funcion para validar si hay respuesta wbem en notificationsd.
#	Chequea el caso en el cual esta escuchando por el puerto (arrancado)
#	ESTO COMO EL CASO DE verify_wbem_data .... HAY QUE RECONDUCIRLO HACIA chk_metric
#
#	OUT:	($rc, $rcstr,$res)
#
#		$rc: 		0->OK / !=0->ERROR
#		$rcstr: 'OK' / Mensaje de error
#		$res:		Valores obtenidos
#
# wbemcli -nl ei 'http://adm:adm1234@10.2.84.161:5988/root/cimv2:Win32_PerfFormattedData_PerfDisk_LogicalDisk.Name="C:"'
#
#----------------------------------------------------------------------------
sub verify_wbem_data  {
my ($self,$desc)=@_;

	my %D=();
	#Para lo que quiero testear cualquier metrica es valida para saber si el agente esta arrancado.
   $D{'mname'}='wmi_num_processes';
	$D{'wbem_user'}=$desc->{'wbem_user'};
	$D{'wbem_pwd'}=$desc->{'wbem_pwd'};
	$D{'host_ip'}=$desc->{'host_ip'};
	$D{'wbem_port'}='5988';
	$D{'namespace'}='/root/cimv2';
	$D{'class'}='Win32_PerfFormattedData_PerfOS_Memory';

   my $res=$self->core_wbem_get(\%D);
   my $rc=$self->err_num();
   my $rcstr=$self->err_str();
   return ($rc, $rcstr,$res);

}

#----------------------------------------------------------------------------
#----------------------------------------------------------------------------
# FUNCIONES AUXILIARES
#----------------------------------------------------------------------------
#----------------------------------------------------------------------------

#----------------------------------------------------------------------------
# Funcion: get_wbem_iids
#----------------------------------------------------------------------------
# Descripcion:
#  Obtiene los valores de las instancias de una clase WBEM.
#  Usada por get_iid
#
# wbemcli -nl  ein 'http://itelsys:cagon10@10.1.254.223:5988/root/cimv2:Win32_PerfRawData_PerfDisk_LogicalDisk'
# 10.1.254.223:5988/root/cimv2:Win32_PerfRawData_PerfDisk_LogicalDisk.Name="C:"
# 10.1.254.223:5988/root/cimv2:Win32_PerfRawData_PerfDisk_LogicalDisk.Name="F:"
# 10.1.254.223:5988/root/cimv2:Win32_PerfRawData_PerfDisk_LogicalDisk.Name="E:"
# 10.1.254.223:5988/root/cimv2:Win32_PerfRawData_PerfDisk_LogicalDisk.Name="_Total"
#
# Nomenclatura WMI:
#  Namespace (/root/cimv2 , /root/WMI)
#  Class (Win32_PerfFormattedData_PerfOS_Memory ...)
#  Instance (iid --> 'ALL', 'C:,D:')
#  Property (AvailableBytes, CacheBytes ....)
#
#----------------------------------------------------------------------------
sub get_wbem_iids  {
my ($self,$desc)=@_;

   $desc->{'wbem_port'}='5988';
   #my $URL='http://'.$desc->{'wbem_user'}.':'.$desc->{'wbem_pwd'}.'@'.$desc->{'host_ip'}.':'.$desc->{'wbem_port'}.$WMINAMESPACE.':'.$desc->{'class'};
   my $URL='http://'.$desc->{'wbem_user'}.':'.$desc->{'wbem_pwd'}.'@'.$desc->{'host_ip'}.':'.$desc->{'wbem_port'}.$desc->{'namespace'}.':'.$desc->{'class'};

   my $cmd=$WBEMCLI_PROG.$WBEMCLI_OPTIONS_IID.$URL;
# OJO este print tiene impacto en get_iid !!!
#print "$cmd";
	$self->log('debug',"get_wbem_iids::[DEBUG] CMD == $cmd");
   my @res=`$cmd 2>&1`;

   # Lo primero es revisar si ha funcionado. Los errores los devuelve por STDOUT y son de la forma:
   # *
   # * /usr/local/bin/wbemcli: Cim: (2) CIM_ERR_ACCESS_DENIED: Access to a CIM resource was not available to the client: "LogonUser()"
   # *
	$self->log('debug',"get_wbem_iids::[DEBUG] res[1] ==".$res[1]);

   if ($res[1] =~ /$WBEMCLI_PROG\:\s*(.+)$/) {
      $self->event_data(["ERROR: $1"]);
      return undef;
   }
	$self->log('debug',"get_wbem_iids::[DEBUG] res ==".@res);
   return \@res;
}


#----------------------------------------------------------------------------
# Funcion: is_wbem_iid
#----------------------------------------------------------------------------
# Descripcion:
#  Chequea si el iid obtenido al hacer el query WMI es valido
#  Basicamente emplea una expresion regular para obtener el iid. Notar que hay casos 
#  en los cuales las instancias WMI no cuelgan de un valor Name (p.ej el exchange)
#
#----------------------------------------------------------------------------
sub is_wbem_iid  {
my ($self,$l)=@_;

	my $iid=undef;
	#Si la linea empieza por '-' no es una instancia, es una propiedad
	if ( $l =~ /^-(.*)/) { return $iid; }
	if ( $l =~ /.*?\=(".+?")\s*$/) {
	#if ( $l =~ /$c\.Name=(".*?")/ ) {
  		$iid=$1;
	}
	return $iid;
}


#----------------------------------------------------------------------------
# Funcion: _wbem_cmd
#----------------------------------------------------------------------------
# Descripcion:
#
# wbemcli  ei 'http://adm:adm1234@10.2.84.161:5988/root/cimv2:Win32_PerfFormattedData_PerfOS_Memory'
# 10.2.84.161:5988/root/cimv2:Win32_PerfFormattedData_PerfOS_Memory.*KEYBINDING="MISSING*" AvailableBytes=365154304,AvailableKBytes=356596,AvailableMBytes=348,CacheBytes=120782848,CacheBytesPeak=129306624,CacheFaultsPersec=0,CommitLimit=2580299776,CommittedBytes=566415360,DemandZeroFaultsPersec=15815,FreeSystemPageTableEntries=34469,PageFaultsPersec=15815,PageReadsPersec=0,PagesInputPersec=0,PagesOutputPersec=0,PagesPersec=0,PageWritesPersec=0,PercentCommittedBytesInUse=21,PoolNonpagedAllocs=50017,PoolNonpagedBytes=9723904,PoolPagedAllocs=67228,PoolPagedBytes=41906176,PoolPagedResidentBytes=41504768,SystemCacheResidentBytes=76931072,SystemCodeResidentBytes=118784,SystemCodeTotalBytes=1114112,SystemDriverResidentBytes=2228224,SystemDriverTotalBytes=4861952,TransitionFaultsPersec=0,WriteCopiesPersec=0
#
# Nomenclatura WMI:
#  Namespace (/root/cimv2 , /root/WMI)
#  Class (Win32_PerfFormattedData_PerfOS_Memory ...)
#  Instance (iid --> 'ALL', 'C:,D:')
#  Property (AvailableBytes, CacheBytes ....)
#
# Si usamos proxy:
# wbemcli -nl  ei 'http://s30labs:Z30lab5@10.1.254.131:5988/_10/_1/_254/_223/root/cimv2:Win32_PerfFormattedData_PerfOS_Memory'
#----------------------------------------------------------------------------
sub _wbem_cmd  {
#my ($self,$desc)=@_;
my ($self,$desc,$mode)=@_;

   $desc->{'wbem_port'}='5988';
   #my $URL='http://'.$desc->{'wbem_user'}.':'.$desc->{'wbem_pwd'}.'@'.$desc->{'host_ip'}.':'.$desc->{'wbem_port'}.$WMINAMESPACE;
   #my $URL='http://'.$desc->{'wbem_user'}.':'.$desc->{'wbem_pwd'}.'@'.$desc->{'host_ip'}.':'.$desc->{'wbem_port'}.$WMINAMESPACE.':'.$desc->{'class'};
	my $URL='';
	my $cmd='';

	if ($mode eq 'instances'){
	   $URL='http://'.$desc->{'wbem_user'}.':'.$desc->{'wbem_pwd'}.'@'.$desc->{'host_ip'}.':'.$desc->{'wbem_port'}.$desc->{'namespace'}.':'.$desc->{'class'};
		$cmd=$WBEMCLI_PROG.$WBEMCLI_OPTIONS.$URL;
	}elsif ($mode eq 'classes'){
      $URL='http://'.$desc->{'wbem_user'}.':'.$desc->{'wbem_pwd'}.'@'.$desc->{'host_ip'}.':'.$desc->{'wbem_port'}.$desc->{'namespace'};
		$cmd="$WBEMCLI_PROG -nl ecn $URL |grep -v '__'|cut -d':' -f3";
   }elsif ($mode eq 'properties'){
      $URL='http://'.$desc->{'wbem_user'}.':'.$desc->{'wbem_pwd'}.'@'.$desc->{'host_ip'}.':'.$desc->{'wbem_port'}.$desc->{'namespace'};
		#$cmd="$WBEMCLI_PROG -nl ecn $URL |grep -v '__'|cut -d':' -f3";
		$cmd="$WBEMCLI_PROG -nl ein $URL:__NAMESPACE |cut -d'=' -f2|cut -d'\"' -f2";
   }else{
		die "MAL MODE";
	}


	#print "$cmd\n";
   # my $cmd=$WBEMCLI_PROG.$WBEMCLI_OPTIONS.$URL;
   return $cmd;
}

#----------------------------------------------------------------------------
# Funcion: _wbem_cmd_iid
#----------------------------------------------------------------------------
# Descripcion:
#
# wbemcli -nl  ein 'http://itelsys:cagon10@10.1.254.223:5988/root/cimv2:Win32_PerfRawData_PerfDisk_LogicalDisk'
# 10.1.254.223:5988/root/cimv2:Win32_PerfRawData_PerfDisk_LogicalDisk.Name="C:"
# 10.1.254.223:5988/root/cimv2:Win32_PerfRawData_PerfDisk_LogicalDisk.Name="F:"
# 10.1.254.223:5988/root/cimv2:Win32_PerfRawData_PerfDisk_LogicalDisk.Name="E:"
# 10.1.254.223:5988/root/cimv2:Win32_PerfRawData_PerfDisk_LogicalDisk.Name="_Total"
#
# Nomenclatura WMI:
#  Namespace (/root/cimv2 , /root/WMI)
#  Class (Win32_PerfFormattedData_PerfOS_Memory ...)
#  Instance (iid --> 'ALL', 'C:,D:')
#  Property (AvailableBytes, CacheBytes ....)
#
#----------------------------------------------------------------------------
sub _wbem_cmd_iid  {
my ($self,$desc)=@_;

   $desc->{'wbem_port'}='5988';
   #my $URL='http://'.$desc->{'wbem_user'}.':'.$desc->{'wbem_pwd'}.'@'.$desc->{'host_ip'}.':'.$desc->{'wbem_port'}.$WMINAMESPACE;
   #my $URL='http://'.$desc->{'wbem_user'}.':'.$desc->{'wbem_pwd'}.'@'.$desc->{'host_ip'}.':'.$desc->{'wbem_port'}.$WMINAMESPACE.':'.$desc->{'class'};
   my $URL='http://'.$desc->{'wbem_user'}.':'.$desc->{'wbem_pwd'}.'@'.$desc->{'host_ip'}.':'.$desc->{'wbem_port'}.$desc->{'namespace'}.':'.$desc->{'class'};

   my $cmd=$WBEMCLI_PROG.$WBEMCLI_OPTIONS_IID.$URL;
   return $cmd;
}


1;
__END__

