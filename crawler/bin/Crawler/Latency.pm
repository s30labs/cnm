#####################################################################################################
# Fichero: (Crawler::Latency.pm) $Id: Latency.pm,v 1.4 2004/10/04 10:38:28 fml Exp $
# Revision: Ver $VERSION
# Descripción: Clase Crawler::Latency
# Set Tab=3
#####################################################################################################
use Crawler;
package Crawler::Latency;
@ISA=qw(Crawler);
$VERSION='1.00';
use strict;
use Net::Ping;
use Time::HiRes;
use Monitor;
use ONMConfig;
use Digest::MD5 qw(md5_hex);

use Data::Dumper;
#----------------------------------------------------------------------------
my $ETXT='KEY-ERROR';
#----------------------------------------------------------------------------
use constant STAT_BAJA => 1;
use constant STAT_MANT => 2;
use constant STAT_ERASE => 3;

#----------------------------------------------------------------------------
my %LATENCY_CACHE=();

#----------------------------------------------------------------------------
my %SLICE_SIZE_VECTOR =( '60' => 20, '300' => 75 );
my %DATA_DIFF=();

#----------------------------------------------------------------------------
# Funcion: Constructor
# Descripcion: Crea un objeto del tipo Crawler::Latency
#----------------------------------------------------------------------------
sub new {
my ($class,%arg) =@_;

   my $self=$class->SUPER::new(%arg);
#   $self->{_cfg} = $arg{cfg} || '';
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
# sanity_check
#----------------------------------------------------------------------------
sub sanity_check  {
my ($self,$ts,$range,$sanity_lapse)=@_;

   local $SIG{CHLD}='';

   my $ts0=$self->log_tmark();
   if ($ts-$ts0>$sanity_lapse) {
      $self->init_tmark();
		#$self->start_crawler($range);

      $self->log('info',"do_task::[INFO] SANITY START");
      my $MAX_OPEN_FILES=8192;
      exec("ulimit -n $MAX_OPEN_FILES && /opt/crawler/bin/crawler -s -c $range");
      #Despues del exec no se puede ponr nada porque se genera un warning
   }
}

#----------------------------------------------------------------------------
# do_task
#----------------------------------------------------------------------------
sub do_task  {
my ($self,$lapse,$range)=@_;
my $NM=0;   #Numero de metricas a procesar
my $NU=0;   #Numero de metricas a con respuesta=U
my $retries=3;


	$self->init_tmark();
	#my $sanity_lapse = $Crawler::SANITY_LAPSE + int(rand(3600));
	my $sanity_lapse = $Crawler::SANITY_LAPSE + int(rand(43200)); #+12h
   #Ajustes de real_lapse
   my $real_lapse = $self->real_lapse($lapse);

   while (1) {

      %DATA_DIFF=();
		%LATENCY_CACHE=();
      my $ts=time;
      $self->sanity_check($ts,$range,$sanity_lapse);

      my $store=$self->store();
      my $dbh=$self->dbh();

      # -----------------------------------------------------------------------
      # Si no hay link, no se ejecutan las tareas
      my @task=();
		my $if=my_if();
      my $link_error=$self->check_if_link($if);
      if ($link_error <= 0) {
         my $rx = $store->get_crawler_task_from_work_file($range,'latency',\@task);
         if (! defined $rx) {
            $self->log('info',"do_task::[INFO] ***TERMINATE*** SIN TAREA PARA $range");
            exit 0;
         }
      }
      else {
         $self->log('warning',"do_task::[WARN] **NO LINK** (error=$link_error)");
      }

      $NM=scalar @task;
      my $mode_flag=$self->mode_flag();
      my ($a,$b,$c)=($mode_flag->{'rrd'}, $mode_flag->{'alert'}, $mode_flag->{'db'});
      $self->log('info',"do_task::[INFO] -R- latency.$lapse|IDX=$range|NM=$NM [rrd=$a alert=$b db=$c]");

my $dump1=Dumper(\@task);
$dump1 =~ s/\n/ /g;
$self->log('debug',"do_task::[DUMPER] task=$dump1");

      my $tnext=time+$real_lapse;

		$NU=0;
		my $nt=0;
      foreach my $desc (@task) {

			$desc->{'lapse'}=$lapse;
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

			my $tp1=Time::HiRes::time();
         #----------------------------------------------------
			my ($rv,$ev)=$self->modules_supported($desc);
			if ((defined $rv->[0]) && ($rv->[0] eq 'U')) {
            $NU+=1;
			}

         #----------------------------------------------------
         $nt += 1;
         my $tpdiffx=Time::HiRes::time()-$tp1;
	 		my $tpdiff=sprintf("%.3f", $tpdiffx);
         $self->log('debug',"do_task::**PROFILE** [$nt|$NM|LAPSE=$tpdiff] TAREA=$task_id [@$rv] WATCH=$desc->{watch}" );
      }

      #----------------------------------------------------
      # 'mon_icmp' => [
      #                 {
      #                   'data' => '1281522011:0.002307',
      #                   'iddev' => '181',
      #                   'iid' => ''
      #                 },

      # Se almacenan datos diferenciales
      $ts=time;

      foreach my $cid_mode_subtype_subtable (keys %DATA_DIFF) {
         my ($cid,$mode_subtype_subtable)=split(/\./,$cid_mode_subtype_subtable);
         my $f=$ts.'-latency-'.$lapse.'-'.$mode_subtype_subtable.'-'.$range;
         my $ftemp='.'.$f;

         my $output_dir="$Crawler::MDATA_PATH/output/$cid/m";
         if (! -d $output_dir) {
            mkdir "$Crawler::MDATA_PATH/output";
            mkdir "$Crawler::MDATA_PATH/output/$cid";
            mkdir $output_dir;
         }

         open (my $fh, ">", "$output_dir/$ftemp");
         foreach my $d (@{$DATA_DIFF{$cid_mode_subtype_subtable}}) {
            print $fh $d->{'iddev'}.';ALL;'.$d->{'data'}."\n";
         }
         close $fh;

         rename "$output_dir/$ftemp","$output_dir/$f";
         $self->log('debug',"do_task::[DEBUG] Creado fichero $output_dir/$f");
      }

      #----------------------------------------------------


      #----------------------------------------------------
      if ($Crawler::TERMINATE == 1) {
         $self->log('info',"do_task::[INFO] ***SIGTERM*** Terminamos recibida signal ...");
         exit 0;
      }

		$self->log_tmark();
      my $wait = $tnext - time;
      if ($wait < 0) {
			$self->log('warning',"do_task::[WARN] *S* latency.$lapse|$real_lapse|IDX=$range|NM=$NM|NU=$NU|WAIT=$wait");
      }
      else {
			$self->log('info',"do_task::[INFO] -W- latency.$lapse|$real_lapse|IDX=$range|NM=$NM|NU=$NU|WAIT=$wait");
         sleep $wait;

         # If $wait>15 min. DB reconnect forced
         if ($wait > 900) {
            $store->close_db($dbh);
            $dbh=$store->open_db();
            $self->dbh($dbh);
            $store->dbh($dbh);
         }

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
# do_task_mth
#----------------------------------------------------------------------------
#sub do_task_mth  {
#my ($self,$lapse,$range)=@_;
#my @task=();
#my $NM=0;   #Numero de metricas a procesar
#my $NU=0;   #Numero de metricas a con respuesta=U
#my $retries=3;
#
#
#	my $tdisp=TDispatch->new();
#	$self->tdisp($tdisp);
#	my $slice_size = $SLICE_SIZE_VECTOR{$lapse} || 75;
#
#   while (1) {
#
#      %LATENCY_CACHE=();
#      my $store=$self->store();
#      my $dbh=$self->dbh();
#
#      # Control de cambios --------------------------------------------------
#      my $reload=$self->get_file_idx($range,\@task);
#      if ($reload) {
#         $self->log('info',"do_task::#RELOAD **reload $range**");
#         my $rv=$store->get_crawler_task_from_file($range,\@task);
#
#         if (!defined $rv) {
#            #En este caso hago la tarea que estuviera contenida en el vector @task
#            $self->log('warning',"do_task::#RELOAD[WARN] Tarea no definida");
#         }
#      }
#      $NM=scalar @task;
#      $self->log('info',"do_task::[INFO] -R- latency.$lapse|IDX=$range|NM=$NM");
#
#      my $tnext=time+$lapse;
#
#      $NU=0;
#
#		#----------------------------------------
#		my $tdisp=$self->tdisp();
#		$tdisp->slice_vector(\@task,$slice_size,'idmetric');
#		$tdisp->tdispatcher(\&do_sub_task,$self);
#      #----------------------------------------------------
#      if ($Crawler::TERMINATE == 1) {
#         $self->log('info',"do_task::[INFO] ***SIGTERM*** Terminamos recibida signal ...");
#         exit 0;
#      }
#      my $wait = $tnext - time;
#      if ($wait < 0) {
#         $self->log('warning',"do_task::[WARN] *S* latency.$lapse|IDX=$range|NM=$NM|NU=$NU|WAIT=$wait");
#      }
#      else {
#         $self->log('info',"do_task::[INFO] -W- latency.$lapse|IDX=$range|NM=$NM|NU=$NU|WAIT=$wait");
#         sleep $wait;
#      }
#      #----------------------------------------------------
#      if ($Crawler::TERMINATE == 1) {
#         $self->log('info',"do_task::[INFO] ***SIGTERM*** Terminamos recibida signal ...");
#         exit 0;
#      }
#
#      #if ($descriptor->{once}) {exit;}
#
#   }
#}


#----------------------------------------------------------------------------
# do_sub_task
#----------------------------------------------------------------------------
sub do_sub_task  {
my ($self,$i,$slice_id,$vector)=@_;
my @task=();
my $NM=0;   #Numero de metricas a procesar
my $NU=0;   #Numero de metricas a con respuesta=U
my $retries=3;

   #-----------------------------------------------
   my $tdisp=$self->tdisp();
   $tdisp->set_thread_table_status($i,1);
   $tdisp->set_work_table_status($slice_id,1);
   #-----------------------------------------------

   #-----------------------------------------------
	# Los handles no se pueden compartir entre threads
   my $store=$self->create_store();
   my $dbh=$store->open_db();
   $self->dbh($dbh);
   $store->dbh($dbh);
   #-----------------------------------------------



#DBG--
	$self->log('debug',"do_sub_task1::[DEBUG] *** START *** THID=$i SLICE_ID=$slice_id");
#/DBG--

	foreach my $desc (@$vector) {

   	my $task_name=$desc->{module};
      my $task_id=$desc->{host_ip}.'-'.$desc->{name};
      $self->task_id($task_id);

#DBG--
         $self->log('debug',"do_sub_task::[DEBUG] *** TAREA=@{[$desc->{name}]} ($task_name) @{[$desc->{host_ip}]}");
#/DBG--

      #----------------------------------------------------
      my $idmetric=$desc->{idmetric};
      if (! defined $idmetric) {
         $self->log('info',"do_sub_task::[WARN] desc SIN IDMETRIC @{[$desc->{name}]} $task_name >> @{[$desc->{host_ip}]} @{[$desc->{host_name}]}");
      }

      #----------------------------------------------------
      my ($rv,$ev)=$self->modules_supported($desc);
      if ((defined $rv->[0]) && ($rv->[0] eq 'U')) {
         $NU+=1;
      }
   }

   #-----------------------------------------------
   $tdisp->set_thread_table_status($i,0);
   $tdisp->set_work_table_status($slice_id,2);
   #-----------------------------------------------
my $o1=ref($dbh);
$self->log('debug',"do_sub_task::[DEBUG] **FML** O1=$o1");
	$store->close_db($dbh);
   #-----------------------------------------------
#DBG--
   $self->log('debug',"do_sub_task1::[DEBUG] *** END *** THID=$i SLICE_ID=$slice_id");
#/DBG--

}




#----------------------------------------------------------------------------
# Funcion: modules_supported
# Descripcion:
# Modulos soportados: mod_monitor, mod_monitor_ext
#----------------------------------------------------------------------------
sub modules_supported  {
my ($self,$desc)=@_;
my $rv=undef;
my $ev=undef;

	$self->event_data([]);
	$self->response('OK');
   my $module=$desc->{module};
  	if ($module =~ /mod_monitor_ext\:(\S+)/i) {
   	$desc->{ext_function}=$1;
      ($rv,$ev)=$self->mod_monitor_ext($desc);
   }
   elsif ($module =~ /mod_monitor/i) { ($rv,$ev)=$self->mod_monitor($desc);}
   else {$self->log('warning',"modules_supported::[WARN] No definido modulo: $module"); }
	return ($rv,$ev);
}


#-------------------------------------------------------------------------------------------
# Funcion: chk_metric
# Descripcion: Valida una determinada metrica y/o monitor asociado
# IN:
#
#  1. $in es una ref a hash con los datos necesarios para identificar metrica+dispositivo.
#     Hay 2 opciones (mejor la a.):
#        a. $in->{'host_ip'} && $in->{'mname'}. Valida a partir de la ip y el nombre de la metrica en cuestion
#        b. $in->{'id_dev'} && $in->{'id_metric'}. Valida a partir del id del device y del id de la metrica en cuestion.
#     El resto de datos se obtienen de la tbla cfg_monitor
#
# OUT:
#     1. El parametro $results es una ref a un array pare guardar los resultados
#     2. El valor de retorno es 0->Sin alerta/1->Con alerta
#		3. Si el resultado es con alerta, el metodo severity debe tener la severidad de la alerta.
#
#-------------------------------------------------------------------------------------------
#mysql>  select id_device,ip,id_alert_type,counter,mname,watch,a.type from alerts a, devices d where a.id_device=d.id_dev order by type;
#+-----------+----------------+---------------+---------+------------------------+------------------------+---------+
#| id_device | ip             | id_alert_type | counter | mname                  | watch                  | type    |
#+-----------+----------------+---------------+---------+------------------------+------------------------+---------+
#|       333 | 172.17.1.20    |             0 |       0 | mon_icmp               | disp_icmp              | latency |
#+-----------+----------------+---------------+---------+------------------------+------------------------+---------+
sub chk_metric {
my ($self,$in,$results,$store)=@_;
my ($rres,$DESCR,$items);
my %desc=();

	if (! defined $store) {
	   $store=$self->create_store();
   	my $dbh=$store->open_db();
   	$self->dbh($dbh);
		$store->dbh($dbh);
	}

	my $dbh=$store->dbh();
	$self->watch(0);

   my $lang = $self->core_i18n_global();
   $self->lang($lang);

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
         $results= [ $lang->{_errornodata}  ];
         return;
      }
   }

   else {
      $rres=$store->get_from_db( $dbh, 'm.monitor,m.params,m.description,m.items,m.module,m.severity', 'cfg_monitor m', "m.monitor=\'$mname\'");
   }

   $desc{'host_ip'}=$ip;
   $desc{'monitor'}=$rres->[0][0];
   $desc{'params'}=$rres->[0][1];
   $DESCR=$rres->[0][2];
   $items=$rres->[0][3];
   $desc{'module'}=$rres->[0][4];
	my $severity=$rres->[0][5];

	# Si es un monitor icmp utilizo el comando de sistema por temas de SUID y apache
	if ( ($desc{'monitor'} eq 'mon_icmp') || ($desc{'monitor'} eq 'mon_ip_icmp2') || ($desc{'monitor'} eq 'mon_ip_icmp3') ) {
		$desc{'monitor'}='mon_icmp_system';
	}

   # Los parametros en tabla se almacenan en parejas param=valor separadas por '|'
   my @p=split(/\|/,$desc{'params'});
   foreach my $l (@p) {
      #my ($k,$v)=split(/=/,$l);
      #$desc{$k}=$v;
		if ($l =~ /^(\w+)\=(.*)$/) {  $desc{$1}=$2; }
   }

#print "VALIDANDO [ip=$desc{host_ip} mname=$mname] [$desc{monitor} $desc{params} $desc{module}]\n";

   #--------------------------------------------------------------------------------------
   my $display_txt = $lang->{'_metric'}.':';
   my $display_txt2 = '';

   push @$results, [$display_txt,$DESCR,''];
	$display_txt = $lang->{'_monitoredvalues'}.':';
   push @$results, [$display_txt, $items, ''];
	$display_txt = $lang->{'_parameters'}.':';
   push @$results, [$display_txt, $desc{'params'}, ''];

   my ($rv,$ev)=$self->modules_supported(\%desc);
	# Si $rv es undef es muy probable que sea un modulo no soportado
   if (! defined $rv) {
      $self->data_out(['U']);
      #return 'U';
      return 0;
   }
   $self->data_out($rv);

#   my  $event_data=$ev->[0];
#	if (ref($rv) ne 'ARRAY') { $rv=['sin datos']; }
#	if (ref($ev) ne 'ARRAY') { $ev=[]; }
#   push @$results, ['Resultado:',"@$rv (@$ev)"];


	# FML Revisar codigo de retorno (rc y rcstr) en los monitores
	# En este caso no existe una variable rc o rcstr y para ver si ha habido
	# error hay que chequearlo en los datos devueltos por el monitor
	my $rc=0;

	if (ref($rv) ne 'ARRAY') { $rc=1; }
	elsif ($rv->[0] eq 'U') { $rc=1; }
	$self->event_data($ev);

	my $data_out="@$rv\n";
   if (scalar @$ev > 0) { $data_out .= "(@$ev)";  }
	$display_txt = $lang->{'_result'}.':';
   push @$results, [$display_txt, $data_out];

   # Si hay un error en la obtencion de datos, se termina. No tiene sentido evaluar watches
   # Se devuelve 0 porque no hay alerta por monitor.
   if ($rc != 0) {
		$self->severity($severity);
		#return 1;
		return 0;
	}

   #--------------------------------------------------------------------------------------
   # Miro si es necesario chequear un monitor asociado a dicha metrica. Solo en el caso en que:
   #  1. La metrica tenga monitor asociado (en alert_type)
   #  2. El monitor este asociado al dispositivo que se esta chequeando
   my $watch=$store->get_from_db( $dbh, 'a.cause,a.severity,a.expr,a.monitor,m.file,m.items,m.top_value', 'alert_type a, metrics m,devices d', "mname=\'$mname\' and m.watch=a.monitor and m.id_dev=d.id_dev and d.ip=\'$ip\'");

   foreach my $w (@$watch) {

      my $cause=$w->[0];
      my $severity=$w->[1];
      my $expr_long=$w->[2];
      my $watch_name=$w->[3];
      my $file=$w->[4];
#		my $rvj = join (', ',@$rv);
		my @items = split (/\|/, $w->[5]);
      my $top_value=$w->[6];

      foreach my $i (0..scalar(@items)-1) {
         my $x=$i+1;
         my $rvj=' | v'.$x.':  '.$items[$i].' = '.$rv->[$i];
         push @$ev,$rvj;
      }

      my %expresions=();
      if ($expr_long =~ /\:/ )  {
         my @aux=split(/:/,$expr_long);
         my $s=1;
         foreach my $e (@aux) {
            if ($e ne '') {$expresions{$s} = $e;}
            $s +=1;
         }
      }
      else { %expresions=( $severity => $expr_long); }

      foreach my $sev (sort keys %expresions) {

         my $expr=$expresions{$sev};
#DBG--
	      $self->log('debug',"chk_metric::[DEBUG] **TEST WATCH (2) => $watch_name => $cause|$expr|$sev**");
#/DBG--
   	   # Si el monitor es de analisis (STEP;v1+v2;5;TOUT) tengo que extraer la expresion.
      	#my ($fx,$expr_orig)=('',$expr);
	      #if ($expr=~/\s*;\s*/) {
   	   #   my @d = split (/\s*;\s*/, $expr);
      	#   $expr=$d[1];
         #	$fx=$d[0];
      	#}

			my ($condition,$lval,$oper,$rval)=$self->watch_eval($expr,$rv,$file,{'top_value'=>$top_value});
			$display_txt = $lang->{'_monitorassociated'}.':';
   	   push @$results, [$display_txt, "$cause ($expr)",''];
			#if (($condition) && (! $fx)) {
			if ($condition) {
            $display_txt = $lang->{'_result'}.':';
            $display_txt2 = '**'.$lang->{'_alert'}."** ($lval $oper $rval)";
            push @$results, [$display_txt, $display_txt2, ''];

            my $ev=$self->event_data();
            $display_txt2 = '**'.$lang->{'_alert'};
            push @$ev," | $display_txt2 ($expr) ($lval $oper $rval)**";
            $self->event_data($ev);

				$self->severity($sev);
				$self->watch($watch_name);
				$self->log('debug',"chk_metric::[DEBUG] ALERTA POR MONITOR: $cause $expr (@$rv) EV=$ev ");
				return 1;
      	}

	      #else {
   	   #   if (! $fx) {   push @$results, ['Resultado Monitor:',"($rvj)",''];  }
      	#   else { push @$results, ['Resultado Monitor:',"($rvj) **NO SE HA VERIFICADO LA FUNCION $fx**",''];  }
			#	return 0;
			#}
		}
   }
	return 0;
}


#----------------------------------------------------------------------------
# Funcion: mod_monitor
# Descripcion:
# @R contiene los valores
#----------------------------------------------------------------------------
sub mod_monitor  {
my ($self,$desc)=@_;
my @D=();
my @event_data=();
my $rc='';

	if (! defined $desc) {return;}

	$SIG{CHLD} = 'IGNORE';
	my $m=$desc->{monitor};

	# Pueden existir varios monitores
	my @M=split(/\|/,$m);
	my $t=time;
	my $items=scalar @M;
#$self->log('debug',"mod_monitor::[DEBUG]*********** m=$m items=$items M=@M");
	foreach my $monitor (@M) {

		$monitor=~s/w_(mon_\w+)-\w+.*/$1/;

		no strict 'refs';
   	my $values=&$monitor($desc);
		use strict 'refs';

#DBG--
$self->log('debug',"mod_monitor::[DEBUG]****>>>MONITOR=$monitor IP=$desc->{host_ip} RES=@$values");
while (my ($kd,$vd) = each %$desc) {
	if (defined $vd) { $kd .= " = $vd"; }
	$self->log('debug',"mod_monitor::[DEBUG]---->>>$kd");
}
#/DBG--


		#Formato de salida
		#1047577725:0.369833 [OK: www.dominio.com->17.26.47.03]

		my $data1=undef;
		my $tm=undef;
		foreach (@$values) {
			if (/^#/) {next;}
			if (/^(\d+)\:(.*?)\s*\[(.*?)\]/) { $tm=$1; $data1=$2; $rc=$3; last;}
		}

		if (!defined $data1) {
			$self->log('warning',"mod_monitor::[WARN] Error en respuesta de $monitor");
			$data1='U';
		}
		push @D,$data1;

		#push @event_data, "MONITOR=$monitor RES=$rc VALOR=$data1";
		push @event_data, $rc;

   }

	my $mode = (exists $desc->{mode}) ? $desc->{mode} : 'gauge' ;
	my $lapse = (exists $desc->{lapse}) ? $desc->{lapse} : 300 ;
   if ($mode=~/gauge/i) {
      if ($lapse !~ /\d+/) { $lapse=300; }
      my $t1 = $t - ($t % $lapse);
      $t=$t1;
   }

   my $data=join(':',$t,@D);
   my $mode_flag=$self->mode_flag();
	
   if ( $mode_flag->{'rrd'} ) {

	   # Almacenamiento RRD --------------------------
		#my $rrd=$desc->{file_path}.$desc->{file};
		my $rrd=$self->data_path().$desc->{file};
   	my $store=$self->store();
		my $type=$desc->{mtype};

	   if ($store) {
   	   #my $mode=$desc->{mode};
        	#my $lapse=$desc->{lapse};
      	if (! -e $rrd) { 
				$store->create_rrd($rrd,$items,$mode,$lapse,$t-600,$type);	
            my $d600=join(':',$t-600,@D);
            $store->update_rrd($rrd,$d600);
            my $d300=join(':',$t-300,@D);
            $store->update_rrd($rrd,$d300);
			}
			my $r = $store->update_rrd($rrd,$data);
         if ($r) {
            my $ru = unlink $rrd;
            $self->log('info',"mod_monitor::[DEBUG] Elimino $rrd  ($ru)");
            $store->create_rrd($rrd,$items,$mode,$lapse,$t-600,$type);
            my $d600=join(':',$t-600,@D);
            $store->update_rrd($rrd,$d600);
            my $d300=join(':',$t-300,@D);
            $store->update_rrd($rrd,$d300);

            $store->update_rrd($rrd,$data);
			}
   	}
	}

   if ( $mode_flag->{'db'} ) {
      my $cid='default';
      if (exists $desc->{'cid'}) { $cid=$desc->{'cid'}; }

      if ( ($cid eq "") || ($desc->{mode} eq "") | ($desc->{'subtype'} eq "") ){
         $self->log('info',"mod_monitor:: VALORES NO VALIDOS $desc->{iddev}.$desc->{subtype} cid=$cid mode=$desc->{mode} subtype=$desc->{subtype}");
      }
		else {	
	     	my $cid_mode_subtype_subtable=$cid.'.'.$desc->{mode}.'-'.$desc->{'subtype'}.'-'.$desc->{'subtable'};
   	   push @{$DATA_DIFF{$cid_mode_subtype_subtable}}, {'iddev'=>$desc->{'iddev'}, 'iid'=>$desc->{'iid'}, 'data'=>$data};
		}
   }


   # Control de alertas --------------------------
	if ( ($mode_flag->{'alert'}) && ($desc->{'status'}==0) ) {
		my $idmetric=$desc->{idmetric};
			my $monitor=$desc->{module}.'&&'.$m;	
   		$self->mod_alert($monitor,$data,$desc,\@event_data);
		#}
	}

	return (\@D,\@event_data);
}


#----------------------------------------------------------------------------
# Funcion: mod_monitor_ext
# Descripcion:
#----------------------------------------------------------------------------
sub mod_monitor_ext  {
my ($self,$desc)=@_;
my @D=();
my @event_data=();
my $rc='';

	if (! defined $desc) {return;}

   if (!defined $desc->{ext_function}) {
      $self->log('warning',"mod_monitor_ext::[WARN] ext_function=UNDEF");
      return;
   }

	$SIG{CHLD} = 'IGNORE';
   my $monitor=$desc->{monitor};

   # No pueden existir varios monitores

   my $t=time;

   $monitor=~s/w_(mon_\w+)_\d+/$1/;  #Considero que monitor sea un watch
   no strict 'refs';
   my $values=&$monitor($desc);
   use strict 'refs';

#DBG--
$self->log('debug',"mod_monitor_ext::[DEBUG]****>>> $monitor $desc->{host_ip} devuelve @$values");
while (my ($kd,$vd) = each %$desc) {
   if (defined $vd) { $kd .= " = $vd"; }
   $self->log('debug',"mod_monitor_ext::[DEBUG]---->>>$kd");
}
#/DBG--

   if (! defined $values) {
      #fml. Se deberia generar un evento.
      return;
   }

   #Formato de salida
   #1047577725:0.369833 [OK: www.itelsys.com->217.126.147.203]

   my $data1=undef;
   my $tm=undef;
   foreach (@$values) {
      if (/^#/) {next;}
		if (/^(\d+)\:(.*?)\s*\[(.*?)\]/) { $tm=$1; $data1=$2; $rc=$3; last;}	
   }

   if (!defined $data1) {
      $self->log('warning',"mod_monitor_ext::[WARN] Error en respuesta de $monitor");
      $data1='U';
   }

   #push @event_data, "MONITOR=$monitor RES=$rc VALOR=$data1";
   push @event_data, $rc;

   no strict 'refs';
   my $res=&{$desc->{ext_function}}($self,$data1);
   use strict 'refs';
	my $items=scalar @$res;

	my $mode = (exists $desc->{mode}) ? $desc->{mode} : 'gauge' ;
	my $lapse = (exists $desc->{lapse}) ? $desc->{lapse} : 300 ;
   if ($mode=~/gauge/i) {
      if ($lapse !~ /\d+/) { $lapse=300; }
      my $t1 = $t - ($t % $lapse);
      $t=$t1;
   }

	my $data=join(':',$t,@$res);

   my $mode_flag=$self->mode_flag();
   if ( $mode_flag->{'rrd'} ) {

	   # Almacenamiento RRD --------------------------
   	#my $rrd=$desc->{file_path}.$desc->{file};
   	my $rrd=$self->data_path().$desc->{file};

	   my $store=$self->store();
   	my $type=$desc->{mtype};

      if ($store) {
         #my $mode=$desc->{mode};
         #my $lapse=$desc->{lapse};
         if (! -e $rrd) { 
				$store->create_rrd($rrd,$items,$mode,$lapse,$t-600,$type); 
            my $d600=join(':',$t-600,@$res);
            $store->update_rrd($rrd,$d600);
            my $d300=join(':',$t-300,@$res);
            $store->update_rrd($rrd,$d300);
			}
         my $r = $store->update_rrd($rrd,$data);
         if ($r) {
            my $ru = unlink $rrd;
            $self->log('info',"mod_monitor_ext::[DEBUG] Elimino $rrd  ($ru)");
            $store->create_rrd($rrd,$items,$mode,$lapse,$t-600,$type);
            my $d600=join(':',$t-600,@$res);
            $store->update_rrd($rrd,$d600);
            my $d300=join(':',$t-300,@$res);
            $store->update_rrd($rrd,$d300);

            $store->update_rrd($rrd,$data);
         }
      }
	}

   if ( $mode_flag->{'db'} ) {
      my $cid='default';
      if (exists $desc->{'cid'}) { $cid=$desc->{'cid'}; }
      if ( ($cid eq "") || ($desc->{mode} eq "") | ($desc->{'subtype'} eq "") ){
         $self->log('info',"mod_monitor:: VALORES NO VALIDOS $desc->{iddev}.$desc->{subtype} cid=$cid mode=$desc->{mode} subtype=$desc->{subtype}");
      }
		else {		
      	my $cid_mode_subtype_subtable=$cid.'.'.$desc->{mode}.'-'.$desc->{'subtype'}.'-'.$desc->{'subtable'};
	      push @{$DATA_DIFF{$cid_mode_subtype_subtable}}, {'iddev'=>$desc->{'iddev'}, 'iid'=>$desc->{'iid'}, 'data'=>$data};
		}
   }

   # Control de alertas --------------------------
	if ( ($mode_flag->{'alert'}) && ($desc->{'status'}==0) ) {
      my $idmetric=$desc->{idmetric};
         my $monitor=$desc->{module}.'&&'.$monitor;
         $self->mod_alert($monitor,$data,$desc,\@event_data);
      #}
   }

	return ($res,\@event_data);
}


#----------------------------------------------------------------------------
# Funcion: ext_dispo_base
# Descripcion:
#----------------------------------------------------------------------------
sub ext_dispo_base  {
my ($self,$val)=@_;

#[Disponible|No computable|No disponible|Desconocido]

	if ($val eq 'U') {return [0,0,1,0]; }
	elsif ($val eq 'D') {return [1,0,0,0]; }
	elsif ($val > 0) {return [1,0,0,0]; }
	else {return [0,0,0,1]; }

}



1;
__END__

