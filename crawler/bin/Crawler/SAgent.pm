#####################################################################################################
# Fichero: (Crawler::SAgent.pm) $Id$ 
# Revision: Ver $VERSION
# Descripción: Clase Crawler::SAgent
# Set Tab=3
#####################################################################################################
use Crawler;
package Crawler::SAgent;
@ISA=qw(Crawler);
$VERSION='1.00';
use strict;
use Digest::MD5 qw(md5_hex);
use SOAP::Lite;
use SOAP::Transport::HTTP;


#----------------------------------------------------------------------------
my $ETXT='KEY-ERROR';
#----------------------------------------------------------------------------
use constant STAT_BAJA => 1;
use constant STAT_MANT => 2;
use constant STAT_ERASE => 3;

#----------------------------------------------------------------------------
my %MODULE_LOCATION = (
   'TPV_GW' => 'Custom',
   'Linux' => 'Base',
   'Windows' => 'Base',
   'WindowsApp' => 'Base',
   'Launcher' => 'Custom',
   'LauncherApp' => 'Custom',
   'AgentBase' => '',

);

#----------------------------------------------------------------------------
my %AGENT_CACHE=();

#----------------------------------------------------------------------------
# Funcion: Constructor
# Descripcion: Crea un objeto del tipo Crawler::Latency
#----------------------------------------------------------------------------
sub new {
my ($class,%arg) =@_;

   my $self=$class->SUPER::new(%arg);
   $self->{_cfg} = $arg{cfg} || '';
   $self->{_version1} = $arg{version1} || '3.23.54';
   $self->{_version2} = $arg{version2} || '1.0.40';
   $self->{_timeout} = $arg{timeout} || 20;

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
   else {
      return $self->{_cfg};
   }
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
# do_task
#----------------------------------------------------------------------------
sub do_task  {
my ($self,$lapse,$range)=@_;
my @task=();
my $NM=0;   #Numero de metricas a procesar
my $NU=0;   #Numero de metricas a con respuesta=U
my $retries=3;


   while (1) {

		%AGENT_CACHE=();
      my $store=$self->store();
      my $dbh=$self->dbh();

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
		$self->log('info',"do_task::#RELOAD[INFO] -R- xagent.$lapse|IDX=$range|NM=$NM");
      my $tnext=time+$lapse;

		$NU=0;
      foreach my $desc (@task) {

         my $task_name=$desc->{module};
         my $task_id=$desc->{host_ip}.'-'.$desc->{name};
         $self->task_id($task_id);


#DBG--
         $self->log('debug',"do_task::[DEBUG] *** TAREA=@{[$desc->{name}]} ($task_name) @{[$desc->{host_ip}]}");
#/DBG--
			
         #----------------------------------------------------
         my $idmetric=$desc->{idmetric};
			if (! defined $idmetric) {
            $self->log('info',"do_task::[WARN] desc SIN IDMETRIC @{[$desc->{name}]} $task_name >> @{[$desc->{host_ip}]} @{[$desc->{host_name}]}");
         }

         #----------------------------------------------------
			my ($rv,$ev)=$self->modules_supported($desc);
			if ((defined $rv->[0]) && ($rv->[0] eq 'U')) {
            $NU+=1;
			}

      }

		my $tnow=time;

		# Actualizo la version del agente en la tabla devices ---------------------------------
		foreach my $ip (keys %AGENT_CACHE) {
#DBG--
         $self->log('debug',"do_task::[DEBUG] ***>> IP=$ip RC=$AGENT_CACHE{$ip}->[0] RCSTR=$AGENT_CACHE{$ip}->[1]");
#/DBG--
			if ($AGENT_CACHE{$ip}->[0] == 0) { 
	         my %D=();
   	      $D{'aping'}=$AGENT_CACHE{$ip}->[1];
				$D{'aping_date'}=$tnow;

				$store->update_db($dbh,'devices',\%D,"ip=\'$ip\'");   
			}
		}

      my $wait = $tnext - $tnow;
      if ($wait < 0) {
			$self->log('warning',"do_task::[WARN] *S* agent.$lapse|IDX=$range|NM=$NM|NU=$NU|WAIT=$wait");
      }
      else {
			$self->log('info',"do_task::[INFO] -W- agent.$lapse|IDX=$range|NM=$NM|NU=$NU|WAIT=$wait");
         sleep $wait;
      }

      #if ($descriptor->{once}) {exit;}

   }
}

#----------------------------------------------------------------------------
# Funcion: modules_supported
# Descripcion:
#----------------------------------------------------------------------------
sub modules_supported  {
my ($self,$desc)=@_;
my $rv=undef;
my $ev=undef;

   my $task_name=$desc->{module};
	# OJO! Tal como se hace el testeo primero hay que poner /mod_remote_app/i
   if ($task_name =~ /mod_remote_app/i) { ($rv,$ev)=$self->mod_remote_app($desc);}
   elsif ($task_name =~ /mod_remote/i) { ($rv,$ev)=$self->mod_remote($desc);}
   else {$self->log('warning',"modules_supported::[WARN] No definida tarea: $task_name"); }
	return ($rv,$ev);
}


#-------------------------------------------------------------------------------------------
# Funcion: chk_metric 
# Descripcion: Valida una determinada metrica de tipo xagent
# IN: 1. Ref a hash con los datos necesarios para identificar metrica+dispositivo. 3 opciones
#			a. ip + mname. Valida a partir de la ip y el nombre de la metrica en cuestion
#			b. id_dev + id_metric. Valida a partir del id del device y del id de la metrica en cuestion.
#			c. ip o id_dev + monitor + [params]. En este caso no es una metricas asociada a dispositivo, 
#				es realmente un tipo de metrica.
#		2. Ref a array pare guardar los resultados
#-------------------------------------------------------------------------------------------
sub chk_metric {
my ($self,$in,$results)=@_;
my %desc=();
my ($ip,$mname,$DESCR,$items,$monitor);

   my $store=$self->create_store();
   my $dbh=$store->open_db();
   $self->dbh($dbh);

	if ( (defined $in->{id_dev}) && (defined $in->{id_metric}) ) {
		# Buscamos ip y mname y los metemos en in
		my $rres=$store->get_from_db( $dbh, 'ip', 'devices', "id_dev=$in->{id_dev}");
		$in->{ip}=$rres->[0][0];
      $rres=$store->get_from_db( $dbh, 'name', 'metrics', "id_metric=$in->{id_metric}");
      $in->{mname}=$rres->[0][0];
	}

	if ( ! defined $in->{monitor} ) {

		if ( (! defined $in->{ip}) && (! defined $in->{mname}) ) {
			# No podemos hacer el chequeo
			$results= [ 'ERROR. NO HAY DATOS' ];
			return;
		}

		($ip,$mname)=($in->{ip}, $in->{mname});
   	my $rres=$store->get_from_db( $dbh, 'c.monitor,c.monitor_data,m.label,m.items,m.watch', 'metric2agent c, metrics m, devices d', "m.id_metric=c.id_metric and d.id_dev=m.id_dev and d.ip=\'$ip\' and m.name=\'$mname\'");

   	$desc{host_ip}=$ip;
   	$desc{monitor}=$rres->[0][0];
   	$desc{params}=$rres->[0][1];
  	 	$DESCR=$rres->[0][2];
   	$items=$rres->[0][3];
   	$desc{module}='mod_remote';
		$monitor=$rres->[0][4];

	}

	# En este caso se ha definido monitor. La metrica no esta asociada.
	else {

		$mname='';
      $desc{host_ip}=$in->{ip};
      $desc{monitor}=$in->{monitor};
      $desc{params}=$in->{params};
      #my $DESCR=$rres->[0][2];
      #my $items=$rres->[0][3];
      $desc{module}='mod_remote';
      #my $monitor=$rres->[0][4];
      $DESCR='descr';
      $items='items';
      $monitor='monitor';


	}

	if ($mname eq 'mon_xagent') { push @$results, ['Titulo:','AGENTE REMOTO NO CONTESTA','']; }
   elsif ($DESCR) { push @$results, ['Titulo:',$DESCR,'']; }
   push @$results, ['Valores monitorizados:', $items, ''];
   push @$results, ['Parametros:', $desc{params}, ''];

   my ($rv,$ev)=$self->modules_supported(\%desc);
	if ($self->err_num()) {
		my $ev=$self->err_str();
		push @$results, ['Resultado:','sin datos',$ev,];
		push @$results, ['Evento:',$ev,''];
	}	
   else {
		#my  $event_data=$ev->[0];
   	if (ref($rv) ne 'ARRAY') { $rv=['sin datos']; }
   	if (ref($ev) ne 'ARRAY') { $ev=[]; }
   	push @$results, ['Resultado:',"@$rv",''];
   	push @$results, ['Evento:',"@$ev",''];
	}

   # Verifico posibles monitores (watches)
   my $watch=$store->get_alert_type_info($dbh,{monitor=>$monitor});
   foreach my $w (@$watch) {

      my $cause=$w->[0];
      my $severity=$w->[1];
      my $expr=$w->[2];
#DBG--
#      $self->log('debug',"mod_alert::[DEBUG ID=$task_id] **TEST WATCH (2) => $monitor => $cause|$expr|$severity**");
#/DBG--
      #$monitor=$monitor.'&&'.$mname;
      push @$results, ['Monitor:', "$cause ($expr)",''];
      my ($condition,$lval,$oper,$rval)=$self->watch_eval($expr,$rv);
      if ($condition) {
         #print "ALERTA POR MONITOR: $cause $expr (@$rv)\n";
         push @$results, ['Resultado:',"**ALERTA** (@$rv)",''];
         $self->severity($severity);
         return 1;

      }
      else { 
			push @$results, ['Resultado:',"(@$rv)",''];  
			return 0;
		}
   }

	return 0;
}

#-------------------------------------------------------------------------------------------
# Funcion: chk_app
# Descripcion: Valida una determinada aplicacion de tipo xagent
# IN: 1. Ref a hash con los datos necesarios para identificar metrica+dispositivo. 3 opciones
#        a. ip + cmd. Valida a partir de la ip y el cmd de la tabla cfg_register_apps (e.j WindowsApp:bios_info)
#        b. id_dev + id_app. Valida a partir del id del device y del id de la aplicacion en cuestion
#			c. ip o id_dev + monitor + params a pelo. Sin necesidad de estar asociada la app al dispositivo.
#			En este caso monitor=cmd
#     2. Ref a array pare guardar los resultados
# OUT:  Ref. a ARRAY que se pasa como parametro-> Tabla con 3 columnas
#-------------------------------------------------------------------------------------------
sub chk_app {
my ($self,$in,$results)=@_;
my %desc=();
my ($ip,$cmd,$DESCR,$items,$monitor,$id_app);

   my $store=$self->create_store();
   my $dbh=$store->open_db();
   $self->dbh($dbh);

 	if ((! defined $in->{ip}) && ( defined $in->{id_dev}) ) {
      my $rres=$store->get_from_db( $dbh, 'ip', 'devices', "id_dev=$in->{id_dev}");
      $in->{ip}=$rres->[0][0];
	}

   if ((! defined $in->{cmd}) && ( defined $in->{id_app}) ) {
      my $rres=$store->get_from_db( $dbh, 'cmd', 'cfg_register_apps', "id_register_app=$in->{id_app}");
      $in->{cmd}=$rres->[0][0];
   }

   if ( ! defined $in->{monitor} ) {

	   if ( (! defined $in->{ip}) && (! defined $in->{id_app}) && (! defined $in->{cmd}) ) {
   	   # No podemos hacer el chequeo
      	$results= [ 'ERROR. NO HAY DATOS' ];
	      return;
   	}

   	($ip,$id_app, $cmd)=($in->{ip}, $in->{id_app}, $in->{cmd});

   	my $rres=$store->get_from_db( $dbh, 'm.cmd,m.params,m.descr', 'cfg_register_apps m', "m.id_register_app=$id_app");

	   $desc{host_ip}=$ip;
   	$desc{monitor}=$rres->[0][0];   #monitor <> cmd
	   $desc{params}=$rres->[0][1];    #params <> params
   	my $DESCR=$rres->[0][2];
   	$desc{module}='mod_remote_app';
	}
	else {

      $desc{host_ip}=$in->{ip};		
      $desc{monitor}=$in->{monitor};   	#monitor <> cmd
      $desc{params}=$in->{params};  #params <> params
      my $DESCR='descr';
      $desc{module}='mod_remote_app';
	}


   if ($DESCR)  { push @$results, ['Titulo:',$DESCR,''];  }
   my ($rv,$ev)=$self->modules_supported(\%desc);
   if ($self->err_num()) {
      my $ev=$self->err_str();
      push @$results, ['Resultado:','sin datos',$ev,''];
      push @$results, ['Evento:',$ev,''];
   }
   else {
      #my  $event_data=$ev->[0];
      if (ref($rv) ne 'ARRAY') { $rv=['sin datos.']; }
      if (ref($ev) ne 'ARRAY') { $ev=[]; }

		# Prepara el resultado generado por la aplicacion. Hay dos casos
		# Interna y con criterio definido para salida de datos (separador: '->')
		# Externa y sin ningun criterio
		my @R=split("\n",$rv->[0]);
		foreach my $v (@R) { 
			if ($v=~/^(.*?)\s*->\s*(.*)$/) { push @$results, [$1,$2,''];  }
			else { push @$results, ['',$v,''];}
		}
  #    push @$results, ['Resultado:',"@$rv",''];
  #    push @$results, ['Evento:',"@$ev",''];
   }
}


#----------------------------------------------------------------------------
# Funcion: ping_agent
# Descripcion: Valida si el agente remoto responde mediante el metodo aping
# IN: $server, $port
# OUT: ($rc,$errstr) $rc=0 si OK. $rcstr=numero de version
#----------------------------------------------------------------------------
sub ping_agent  {
my ($self,$server,$port)=@_;

	my ($rc,$errstr);
	eval {
      my $soap= SOAP::Lite
         -> uri("http://$server/Custom/Launcher")
         -> proxy("http://$server:$port");

      $soap->transport->timeout(3);
      my $result = $soap->aping();

      if ($result->fault) {
         $errstr= join ', ', $result->faultcode, $result->faultstring, $result->faultdetail;
         $self->log('warning',"mod_remote::[WARN] acceso a aping($server:$port) RC=$errstr");
         $self->err_num($result->faultcode);
         $self->err_str($errstr);
			$rc=$result->faultcode;
      }
      else { $errstr=$result->result(); }

   };
   if ($@) {
      $errstr=$@;
      $errstr =~ s/(.*?)at \/opt.*$/$1/s;
      $self->log('warning',"mod_remote::[WARN] al ejecutar aping $errstr");
      $self->err_num(1);
      $self->err_str($errstr);
		$rc=1;
   }
   else {
		$rc=0;
      $self->log('debug',"mod_remote::[DEBUG] aping OK ($errstr)");
   }

	if ($rc == 500) { $errstr='Sin respuesta (500)';}
	return ($rc,$errstr);
}


#----------------------------------------------------------------------------
# Funcion: mod_remote
# Descripcion:
# IN: $desc->{'host_ip'}, $desc->{monitor}, $desc->{params}
#----------------------------------------------------------------------------
sub mod_remote  {
my ($self,$desc)=@_;
my @D=();
my @event_data=();
my @values=();
my $rc=0;
my $rcstr='OK';
my $response;
my $items;
my ($m,$f);

	my $t=time;
	if (! defined $desc) {
      $rcstr="[WARN] Modulo/Metodo mal invocado. Faltan parametros";
      $self->log('warning',"mod_remote::$rcstr");
      push @values, $t, 'U';
      push @event_data, $rcstr;
		return (\@values,\@event_data);
	}

   #-------------------------------------------------------------------
   my $task_id=$self->task_id();

   #-------------------------------------------------------------------
   # Valido que el agente instalado en el dispositivo responda a las 
	# peticiones del servidor.
   #-------------------------------------------------------------------
   my $server=$desc->{'host_ip'} || 'localhost';
   my $port='7691';
   if (! exists $AGENT_CACHE{$server}) { 
		my ($rc,$rcstr)=$self->ping_agent($server, $port); 
		$AGENT_CACHE{$server}=[$rc, $rcstr];
	}

   #-------------------------------------------------------------------
	# Si el agente no responde bien al aping. No sigo interrogandole por otras metricas.
   #-------------------------------------------------------------------
	my $data_noagent=undef;
   if (( exists $AGENT_CACHE{$server}) && ($AGENT_CACHE{$server}->[0] != 0)) {
      my $rc=$AGENT_CACHE{$server}->[0];
      my $rcstr=$AGENT_CACHE{$server}->[1];
      $self->log('info',"mod_remote::[INFO ID=$task_id] CACHE de $server=U => NOAGENT RC=$rc RCSTR=$rcstr**");
      push @values, $t, 'U';
      $data_noagent = $t.':'.'NOAGENT';
      push @event_data, $rcstr;
      #return (\@values,\@event_data);
   }

	else {
		#--------------------------------------------------------------------------
		# Cliente SOAP
		# monitor es del tipo: Windows:num_threads
		#--------------------------------------------------------------------------
   	$server=$desc->{'host_ip'} || 'localhost';
   	$port='7691';
		my $m1=$desc->{monitor};
   	($m,$f)=split(/\:/,$m1,2);
		my $monitor=$m;
   	if ($MODULE_LOCATION{$m})  {$monitor=$MODULE_LOCATION{$m}.'/'.$m; }

	   if ((! $f) || (! $monitor) ) {
			$rcstr="[WARN] Modulo/Metodo mal definido ($m)";
      	$self->log('warning',"mod_remote::$rcstr");
			$self->err_num(1);
			$self->err_str($rcstr);
      	push @values, $t, 'U';
	      push @event_data, $rcstr;
		   #return ([],[]);
   	}

   	my %P=();
		my $params=$desc->{params};
   	if ($params) {
      	my @p=split(/\,/,$params);
	      foreach my $i (@p) {
   	      if ($i =~ /^\s*(\S+)\s*\=\s*(.+)$/) {
					$P{$1} = $2; 
#DBG--
					$self->log('debug',"mod_remote::[DEBUG] PARAMS $1=>$2");
#/DBG--
				}
      	}
   	}

#DBG--
		$self->log('debug',"mod_remote::[DEBUG]****>>>MONITOR=$monitor PARAMS=$params IP=$desc->{host_ip}");
		my $debug='';
		while (my ($kd,$vd) = each %$desc) {
   		if (defined $vd) { $debug .= "$kd: $vd <> "; }
		}
		$self->log('debug',"mod_remote::[DEBUG] DESC=$debug");
#/DBG--


		eval {
	   	my $soap= SOAP::Lite
   	   	-> uri("http://$server/$monitor")
      		-> proxy("http://$server:$port");

			my $timeout=$self->timeout();
			$soap->transport->timeout($timeout);

			my $result = $soap->$f(\%P);

			if ($result->fault) {
     			my $errstr= join ', ', $result->faultcode, $result->faultstring, $result->faultdetail;
				$self->log('warning',"mod_remote::[WARN] acceso a $monitor ($desc->{host_ip}) RC=$errstr");
		      $self->err_num($result->faultcode);
   		   $self->err_str($errstr);
	      	$t=time;
   	   	push @values, $t, 'U';
      		push @event_data, $rcstr;
				#return ([],[]);
			}
			$response=$result->result();

		};
		if ($@) { 
			$rcstr=$@;
			$rcstr =~ s/(.*?)at \/opt.*$/$1/s;
			$self->log('warning',"mod_remote::[WARN] $rcstr");  
      	$self->err_num(1);
	      $self->err_str($rcstr);
			$t=time;
			push @values, $t, 'U';
			push @event_data, $rcstr;
			#return([],[]); 
		}
   	else { 

			$self->log('debug',"mod_remote::[DEBUG] MONITOR=$monitor IP=$desc->{host_ip} RES=$response"); 

			#--------------------------------------------------------------------------
			#Formato de salida
			#1047577725:0.369833 [OK: www.dominio.com->17.26.47.03]
			# Se puede valorar que el formato de respuesta sea xml (timestamp,mname,num.datos,dato1,valor1,rc1,rcstr1....)

			# $response --> @values --> $values[0]=timestamp. Se pone el del servidor CNM. --> $data
  			$response =~ s/\s//;
  			@values=split(/\:/,$response);
  			$items=(scalar @values) - 1;
  			$t=time;
  			$values[0]=$t;
		}
	}

	
	# --------------------------------------------------------------------------------
	my $data=join(':',@values);
   my $mode_flag=$self->mode_flag();
   if ( $mode_flag->{rrd} ) {

	   # Almacenamiento RRD --------------------------
		#my $rrd=$desc->{file_path}.$desc->{file};
		my $rrd=$self->data_path().$desc->{file};

   	my $store=$self->store();
		my $type=$desc->{mtype};

	   if ($store) {
   	   my $mode=$desc->{mode};
      	if (! -e $rrd) {
         	my $lapse=$desc->{lapse};
         	$store->create_rrd($rrd,$items,$mode,$lapse,$t,$type);
      	}
      	$store->update_rrd($rrd,$data);
   	}
	}


   # Control de alertas --------------------------
	if ($mode_flag->{alert}) {
		my $idmetric=$desc->{idmetric};
		my $monitor=$desc->{module}.'&&'.$m;	
      if (defined $data_noagent) {  $self->mod_alert($monitor,$data_noagent,$desc,\@event_data);  }
		else { $self->mod_alert($monitor,$data,$desc,\@event_data); }
	}

	shift @values;
	return (\@values,\@event_data);
}



#----------------------------------------------------------------------------
# Funcion: mod_remote_app
# Descripcion: Similar a mod_remote pero para ejecutar aplicaciones.
# Esto significa que no hay formateo de datos ni almacenamiento rrd.
# IN: $desc->{'host_ip'}, $desc->{monitor}, $desc->{params}
#----------------------------------------------------------------------------
sub mod_remote_app  {
my ($self,$desc)=@_;
my @D=();
my $event_data='-';
my $rc=0;
my $rcstr='OK';
my $response = 'sin datos';

   if (! defined $desc) {return;}

   #--------------------------------------------------------------------------
   # Cliente SOAP
   # monitor es del tipo: TPV_GW:calls_datafono_protocol_ratio
   #--------------------------------------------------------------------------
   my $server=$desc->{'host_ip'} || 'localhost';
   my $port='7691';
   my $m1=$desc->{monitor};
   my ($m,$f)=split(/\:/,$m1,2);
   my $monitor=$m;
   if ($MODULE_LOCATION{$m})  {$monitor=$MODULE_LOCATION{$m}.'/'.$m; }

   if ((! $f) || (! $monitor) ) {
      $rcstr="[WARN] Modulo/Metodo mal definido ($m)";
      $self->log('warning',"mod_remote_app::$rcstr");
      $self->err_num(1);
      $self->err_str($rcstr);
      return ([$response],[$rcstr]);
   }

   my %P=();
   my $params=$desc->{params};
   if ($params) {
      my @p=split(/\,/,$params);
      foreach my $i (@p) {
         if ($i =~ /^\s*(\S+)\s*\=\s*(.+)$/) {$P{$1} = $2; }
      }

   }

#DBG--
$self->log('debug',"mod_remote_app::[DEBUG]****>>>MONITOR=$monitor (F=$f) PARAMS=$params IP=$desc->{host_ip}");
while (my ($kd,$vd) = each %$desc) {
   if (defined $vd) { $kd .= " = $vd"; }
   $self->log('debug',"mod_remote_app::[DEBUG]---->>>$kd");
}
#/DBG--


   eval {
      my $soap= SOAP::Lite
         -> uri("http://$server/$monitor")
         -> proxy("http://$server:$port");


      my $timeout=$self->timeout();
      $soap->transport->timeout($timeout);

      my $result = $soap->$f(\%P);

      if ($result->fault) {
         my $errstr= join ', ', $result->faultcode, $result->faultstring, $result->faultdetail;
         $self->log('warning',"mod_remote_app::[WARN] acceso a $monitor (F=$f) ($desc->{host_ip}) RC=$errstr");
         $self->err_num($result->faultcode);
         $self->err_str($errstr);
         return ([$response],[$result->faultstring]);
      }

      $response=$result->result();

   };
   if ($@) {
      $rcstr=$@;
      $rcstr =~ s/(.*?)at \/opt.*$/$1/s;
      $self->log('warning',"mod_remote_app::[WARN] $rcstr");
      $self->err_num(1);
      $self->err_str($rcstr);
      return([$response],[$rcstr]);
   }
   else { $self->log('debug',"mod_remote_app::[DEBUG] MONITOR=$monitor (F=$f) IP=$desc->{host_ip} RES=$response"); }



$self->log('info',"notificationsd fffmmmlll::[DEBUG] MONITOR=$monitor (F=$f) IP=$desc->{host_ip} RES=$response");


   return ([$response],[$event_data]);
}



1;
__END__

