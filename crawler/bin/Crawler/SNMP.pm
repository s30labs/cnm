#################################################################################
# Fichero: Crawler::SNMP.pm
# Description: Clase Crawler::SNMP
# Set Tab=3
#--------------------------------------------------------------------------------
#
#	modules_supported
#--------------------------------------------------------------------------------
#		mod_snmp_get (metricas snmp clase1 y 2) cfg=1,2 custom=0,1
#			core_snmp_get						:	OUT=$values
#			core_snmp_table + CACHE_SNMP	:	OUT=$values
#		$values es una referencia a un array con los datos obtenidos (v1 v2  vn)
#		$values se transforma  en una cadena del tipo time:v1:v2 ....vn para el modulo rrd
#
#			modulo rrd (if $mode_flag->{rrd})
#				[create_rrd] + update_rrd
#
#			mod_alert (if $mode_flag->{alert})
#
#--------------------------------------------------------------------------------
#		mod_snmp_get_ext:(fx)  (metricas snmp clase1 y 2) cfg=1,2 custom=0,1
#        core_snmp_get                 :  OUT=$values1
#        core_snmp_table + CACHE_SNMP  :  OUT=$values1
#			ext_function($values)			:	OUT=$values (salida de ext_function)	
#     $values es una referencia a un array con los datos obtenidos (v1 v2  vn)
#     $values se transforma  en una cadena del tipo time:v1:v2 ....vn para el modulo rrd
#
#        modulo rrd (if $mode_flag->{rrd})
#           [create_rrd] + update_rrd
#
#        mod_alert (if $mode_flag->{alert})
#
#
#--------------------------------------------------------------------------------
#		mod_snmp_walk:(fx)(px) (metricas snmp especiales,clase3)
#			core_snmp_table (CACHE_SNMP) + core_snmp_esp (si existe)  :
#				
#
#--------------------------------------------------------------------------------
#	OUT: ($rv,$ev)
#
#		$rv:	Es una referencia a un array con los datos obtenidos por core_snmp_xxx,
#				core_snmp_xxx + ext_function ...		(v1 v2  vn).
#
#		$ev:	Es una referencia al array de eventos (@EVENT_DATA) que se maneja con el
#				metodo $self->event_data definido en la clase padre.
#				En cada iteracion hay que resetearlo porque al hacer push de datos podriamos tener
#				Un crecimiento de memoria descontrolado !!!!
#				Contiene los datos proporcionados por los modulos de bajo nivel (core_snmp_xxxx)
#				mod_alert tambien puede modificarlo para tipos concretos (NOSNMP ...)
#
#
#
##################################################################################
use Crawler;
package Crawler::SNMP;
@ISA=qw(Crawler);
$VERSION='1.00';
use strict;
use SNMP;
use JSON;
use Digest::MD5 qw(md5_hex);
use Metrics::Base;
use ONMConfig;
use Crawler::FXM::Plugin;
use Enterprises;
use MIBTypes;
use Data::Dumper;
use File::Path qw(make_path);
use Time::HiRes;

#-----------------------------------------------------------------------
use ProvisionLite::snmp_serial_functions;
#-----------------------------------------------------------------------
%ProvisionLite::Serialfx = (

   	'cisco' => \&ProvisionLite::snmp_serial_functions::snmp_fx_serialn_by_entity,
);


#----------------------------------------------------------------------------
# Hash para cachear los valores obtenidos de un dispositivo mediante un walk
# Si la clave es una ip (chequeo si el host responde por SNMP):
#
# 		$SNMP_CACHE{$ip}=[$rc,$rcstr,$res];
#
# Si la clave es el conjunto de oid + ip (chequeo una metrica concreta)
#
#		$SNMP_CACHE{$ip}=[$rc,$rcstr,\@values];
#
my %SNMP_CACHE=();
my %SNMP_CACHE_RAW=();
my %SNMP_CACHE_TO_OID=(); # Mapeo de task-id a OID para diferenciar metricas con varios OIDs posibles (traffic_mibii_if)

#----------------------------------------------------------------------------

#----------------------------------------------------------------------------
my @EVENT_DATA=();
my %U=();	#Hash con quellos dispositivos que no responden
my $ETXT='KEY-ERROR';
#----------------------------------------------------------------------------
use constant STAT_BAJA => 1;
use constant STAT_MANT => 2;
use constant STAT_ERASE => 3;

#----------------------------------------------------------------------------
# Traduccion de algunos de los codigos de retorno del SNMP a algo mas
# amigable de cara al usuario.
my %RCSTR2USER =(

	'2' => 'El OID no existe en el dispositivo',
);

#----------------------------------------------------------------------------
# Vector que mapea oid numerico con nombre. Se rellena dinamicamente con la funcion:
#	_get_oid_mapping
my %OID2TXT =();
my $FILE_CACHE_MAPPING='/opt/data/mdata/input/idx/oid_mapping_cache';
my $FILE_CACHE_MAPPING_MD5='/opt/data/mdata/input/idx/oid_mapping_cache.sign';

#----------------------------------------------------------------------------
# Numero de elementos medidos por la metrica
# No tiene porque ser igual que el numero de oids !!!
my $MITEMS=0;

#----------------------------------------------------------------------------
my %SLICE_SIZE_VECTOR =( '60' => 24, '300' => 1200 );
my %DATA_DIFF=();

#----------------------------------------------------------------------------
# Funcion: Constructor
# Descripcion: Crea un objeto del tipo Crawler::SNMP
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
sub hex2ascii {
my ($self,$data)=@_;

   # Es una mac
   if ($data =~ /^"*\s*(\w{2}\s{1}\w{2}\s{1}\w{2}\s{1}\w{2}\s{1}\w{2}\s{1}\w{2})\s*"*$/) {
      $data =~ s/"(.+?)"/$1/;
      my @l=split(/\s+/,$data);
      return lc join(':', @l);
   }

   if ($data !~ /(\w{2}\s{1}){4}/) { return $data;}

   $data =~ s/"(.+?)"/$1/;
   $data =~ s/^(.*)\s+00\s*$/$1 2E/g;
   my @l=split(/\s+/,$data);

   #El ultimo valor suele estar mal en w2k
#  pop @l;

   my $newdata=pack("C*",map(hex,@l));
   return $newdata;

}


#------------------------------------------------------------------------------
sub errstr2es {
my ($self,$txt)=@_;
my %errors=(

   'Timeout'=>'Sin respuesta SNMP',
   'Unknown Object Identifier' => 'El OID no existe en el dispositivo',
);

   my $txtmod=$txt;
   if ($errors{$txt}) { $txtmod=$errors{$txt}; }
   return $txtmod;
}


#------------------------------------------------------------------------------
sub clear_cache  {
my $self=shift;

	%SNMP_CACHE=();
	%SNMP_CACHE_RAW=();
	%SNMP_CACHE_TO_OID=();
}

#------------------------------------------------------------------------------
sub init_cache_oids  {
my ($self,$tasks)=@_;

   %SNMP_CACHE_TO_OID=();

	foreach my $desc (@$tasks) {

		if ($desc->{'cfg'} != 2 ) { next; }
		my $cache_key=$desc->{'host_ip'}.'.'.$desc->{'name'};
		$SNMP_CACHE_TO_OID{$cache_key} = $self->_oid_prepare($desc->{oid});
	}

}

#----------------------------------------------------------------------------
# Funcion: get_snmp_credentials
# Obtiene las credenciales snmp de un dispositivo dado de alta en el sistema.
# IN: $data (ref a hash). Contiene los campos 'ip' o 'id_dev' para 
#		identificar el dispositivo.
# OUT: \%snmp_cfg (ref a hash) con los campos rellenos segun snmp v1/v2 o v3.
#----------------------------------------------------------------------------
sub get_snmp_credentials  {
my ($self,$data)=@_;
	
   my %snmp_cfg = ();
   # Si se especifica la opcion i. Se busca en BBDD a partir de la IP los parametros snmp
   my $store=$self->store();
	if ($store eq '') {
		$self->create_store();
		$store=$self->store();
	}

   my $dbh=$self->dbh();
   if (!defined $dbh ) {
		$dbh=$store->open_db();
		$self->dbh($dbh);	
   }

	my $condition='';
	if (exists $data->{'ip'}) { $condition = "ip=\'".$data->{'ip'}."\'"; }
	elsif ( exists $data->{'id_dev'}) { $condition = "id_dev=\'".$data->{'id_dev'}."\'"; }
	else { return \%snmp_cfg; }

   my $rv=$store->get_from_db($dbh,'community,version,ip','devices',$condition);
   if (!defined $rv) {
      $self->log('warning',"get_command_options::[WARN] ERROR en query devices cond >> $condition");
		return \%snmp_cfg;
   }

   $snmp_cfg{'community'}=$rv->[0][0];
   $snmp_cfg{'version'}=$rv->[0][1];
	$snmp_cfg{'host_ip'}=$rv->[0][2];

   if ($snmp_cfg{'version'} == 3) {

      my $id_profile=$snmp_cfg{'community'};
      my $v3 = $store->get_profiles_snmpv3($dbh,[$id_profile]);

      $snmp_cfg{'sec_name'}=$v3->{$id_profile}->{'sec_name'};
      $snmp_cfg{'sec_level'}=$v3->{$id_profile}->{'sec_level'};
      $snmp_cfg{'auth_proto'}=$v3->{$id_profile}->{'auth_proto'};
      $snmp_cfg{'auth_pass'}=$v3->{$id_profile}->{'auth_pass'};
      $snmp_cfg{'priv_proto'}=$v3->{$id_profile}->{'priv_proto'};
      $snmp_cfg{'priv_pass'}=$v3->{$id_profile}->{'priv_pass'};
   }

	return \%snmp_cfg;
}


#----------------------------------------------------------------------------
# Funcion: get_command_options
# Descripcion:
#  1.Obtiene los parametros introducidos por linea de comandos.
#  2.Devuelve los valores en un hash.
#  La opcion M permite especificar en el caso de ser una tabla si hay que considerar
#  el Index como primera columna de la misma. Si existe columna Index (definida en la MIB) 
#  no hace falta especificar esta opcion (M=0). Si no existe la columna Index, se especifican
#  las columnas que se saltan. Habitualmente M=1
#----------------------------------------------------------------------------
sub get_command_options  {
my ($self,$snmp_cfg)=@_;

use Getopt::Std;

	my %opts=();
	my $USAGE="Uso: $0 -v version [-c comunity] [-u sec_name -l sec_level -a auth_proto -A auth_pass -x priv_proto -X priv_pass] -n host\nOpciones especiales: w->txt|html f->descriptor xml (mibt) o->oid z->last";
	getopts("v:c:u:l:a:A:x:X:n:h:w:f:o:z:M:i",\%opts);

	if ($opts{'n'}) { $snmp_cfg->{'host_ip'}=$opts{'n'};  }
	else { die "$USAGE\n"; }

	if ($opts{'i'}) {

		my %data=();
		$data{'ip'}=$snmp_cfg->{'host_ip'};
		my $cfg=$self->get_snmp_credentials(\%data);

		$snmp_cfg->{'community'}=$cfg->{'community'};
		$snmp_cfg->{'version'}=$cfg->{'version'};

      if ($snmp_cfg->{'version'} == 3) {

         $snmp_cfg->{'sec_name'}=$cfg->{'sec_name'};
         $snmp_cfg->{'sec_level'}=$cfg->{'sec_level'};
         $snmp_cfg->{'auth_proto'}=$cfg->{'auth_proto'};
         $snmp_cfg->{'auth_pass'}=$cfg->{'auth_pass'};
         $snmp_cfg->{'priv_proto'}=$cfg->{'priv_proto'};
         $snmp_cfg->{'priv_pass'}=$cfg->{'priv_pass'};
      }
	}
	else {

		if (! $opts{'v'}) { $snmp_cfg->{'version'} = 1; }
		else { $snmp_cfg->{'version'}=$opts{'v'};	 }

		#----------------------------------------------------------------------
		if ($snmp_cfg->{'version'} eq '3') {
			if ($opts{'u'}) { $snmp_cfg->{'sec_name'}=$opts{'u'}; }
			else {die "$USAGE\n"; }

			if ($opts{'l'}) { $snmp_cfg->{'sec_level'}=$opts{'l'}; }
			 else {die "$USAGE\n"; }

			if (($opts{'a'}) && ($opts{'a'}=~/\w+/) ) { $snmp_cfg->{'auth_proto'}=$opts{'a'}; }
			else { $snmp_cfg->{'auth_proto'}='MD5'; }

			if ($opts{'A'}) { $snmp_cfg->{'auth_pass'}=$opts{'A'}; }
			else { die "$USAGE\n"; }

			if (($opts{'x'}) && ($opts{'x'}=~/\w+/) ) { $snmp_cfg->{'priv_proto'}= $opts{'x'}; }
			else { $snmp_cfg->{'priv_proto'}='AES'; }

			if ($opts{'X'}) { $snmp_cfg->{'priv_pass'}=$opts{'X'}; }
		}
		#----------------------------------------------------------------------
		else {
			$snmp_cfg->{'community'}=$opts{'c'} || 'public';
		}
	}

	#legacy, por las utilidades de libexec
	$snmp_cfg->{'format'} = (defined $opts{'w'}) ? $opts{'w'} : 'txt';
	$snmp_cfg->{'start_col'} = (defined $opts{'M'}) ? $opts{'M'} : 0;
	$snmp_cfg->{'descriptor'} = $opts{'f'};
	$snmp_cfg->{'last'} = $opts{'z'};
	$snmp_cfg->{'oid'} = $opts{'o'};

}


#----------------------------------------------------------------------------
# Funcion: get_command_options_ext
# Descripcion:
#  Identico a get_command_options pero recibe el vector %opts como parametro
#----------------------------------------------------------------------------
sub get_command_options_ext  {
my ($self,$opts,$snmp_cfg)=@_;

   if ($opts->{'n'}) { $snmp_cfg->{'host_ip'}=$opts->{'n'};  }
   else { return undef; }

   if ($opts->{'i'}) {

      my %data=();
      $data{'ip'}=$snmp_cfg->{'host_ip'};
      my $cfg=$self->get_snmp_credentials(\%data);

      $snmp_cfg->{'community'}=$cfg->{'community'};
      $snmp_cfg->{'version'}=$cfg->{'version'};

      if ($snmp_cfg->{'version'} == 3) {

         $snmp_cfg->{'sec_name'}=$cfg->{'sec_name'};
         $snmp_cfg->{'sec_level'}=$cfg->{'sec_level'};
         $snmp_cfg->{'auth_proto'}=$cfg->{'auth_proto'};
         $snmp_cfg->{'auth_pass'}=$cfg->{'auth_pass'};
         $snmp_cfg->{'priv_proto'}=$cfg->{'priv_proto'};
         $snmp_cfg->{'priv_pass'}=$cfg->{'priv_pass'};
      }
   }
   else {

      if (! $opts->{'v'}) { $snmp_cfg->{'version'} = 1; }
      else { $snmp_cfg->{'version'}=$opts->{'v'};  }

      #----------------------------------------------------------------------
      if ($snmp_cfg->{'version'} eq '3') {
         if ($opts->{'u'}) { $snmp_cfg->{'sec_name'}=$opts->{'u'}; }
         else { return undef; }

         if ($opts->{'l'}) { $snmp_cfg->{'sec_level'}=$opts->{'l'}; }
          else { return undef; }

         if (($opts->{'a'}) && ($opts->{'a'}=~/\w+/) ) { $snmp_cfg->{'auth_proto'}=$opts->{'a'}; }
         else { $snmp_cfg->{'auth_proto'}='MD5'; }

         if ($opts->{'A'}) { $snmp_cfg->{'auth_pass'}=$opts->{'A'}; }
         else { return undef; }

         if (($opts->{'x'}) && ($opts->{'x'}=~/\w+/) ) { $snmp_cfg->{'priv_proto'}= $opts->{'x'}; }
         else { $snmp_cfg->{'priv_proto'}='AES'; }

         if ($opts->{'X'}) { $snmp_cfg->{'priv_pass'}=$opts->{'X'}; }
      }
      #----------------------------------------------------------------------
      else {
         $snmp_cfg->{'community'}=$opts->{'c'} || 'public';
      }
   }

   #legacy, por las utilidades de libexec
   $snmp_cfg->{'format'} = (defined $opts->{'w'}) ? $opts->{'w'} : 'txt';
   $snmp_cfg->{'start_col'} = (defined $opts->{'M'}) ? $opts->{'M'} : 0;
   $snmp_cfg->{'descriptor'} = $opts->{'f'};
   $snmp_cfg->{'last'} = $opts->{'z'};
   $snmp_cfg->{'oid'} = $opts->{'o'};

	return 1;
}




#----------------------------------------------------------------------------
# Funcion: reset_mapping
# Descripcion:
#	1. Resetea el vector OID2TXT (asocia oid -> oidn)
#	2. Obtiene los valores de la BBDD y lo actualiza
#	3. Genera el fichero $FILE_CACHE_MAPPING con los valores y devuelve la firma
#		MD5 del contenido para que los crawlers en cada iteracion lo chequeen y
#		validen si ha sido modificado.
#	Otro proceso sera el encargado de chequear la BBDD para ver posibles
#	modificaciones (cnm-watch)
#----------------------------------------------------------------------------
sub reset_mapping   {
#my $self=shift;
my $self=shift;

   %OID2TXT=();
   $self->_get_oid_mapping(\%OID2TXT);
	my $ro=open (F, ">$FILE_CACHE_MAPPING");
	if (! $ro) {
		$self->log('warning',"reset_mapping:: [WARN] Can't update $FILE_CACHE_MAPPING ($!) - workload configured ?");
		return;
	}

	my $r='';
   while (my ($k,$v) = each %OID2TXT) {
		$r.=$k; $r.=$v;
		print F "$k;$v\n";
	}
	close F;

	$ro=open (F, ">$FILE_CACHE_MAPPING_MD5");
   if (! $ro) {
      $self->log('warning',"reset_mapping:: [ERROR] Al abrir $FILE_CACHE_MAPPING_MD5 en escritura");
      return;
   }
	my $sign=md5_hex($r);
	print F $sign;
	close F;

	$self->log('info',"reset_mapping:: [INFO] RES=OK (NEW_MD5=$sign) ");

	return $sign;
}


#----------------------------------------------------------------------------
# Funcion: check_mapping
# Descripcion:
#  1. Chequea si ha cambiado el MD5 de los mapeos oid->oidn
#	2. Lee el contenido de FILE_CACHE_MAPPING_MD5 y si ha cambiado su valor
#		devuelve un 1.
#----------------------------------------------------------------------------
sub check_mapping   {
my ($self, $actual_md5) = @_;

	my $change=0;
	my $fh;

	# Contiene una linea con el hash.
   if (! open($fh, "<", $FILE_CACHE_MAPPING_MD5))  {
		$self->log('warning',"check_mapping::[ERROR] Al abrir el fichero $FILE_CACHE_MAPPING_MD5 en lectura " );
		return $change;	
	}
   my $last_md5=<$fh>;
   close $fh;
   chomp $last_md5;

	if ($actual_md5 ne $last_md5) { $change=1; }

#DBG--
   $self->log('debug',"check_mapping::[DEBUG] *** MD5_ACTUAL=$actual_md5 MD5_FILE=$last_md5 CHANGE=$change (FILE=$FILE_CACHE_MAPPING_MD5)" );
#/DBG--

   return $change;
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
my @task=();
my $NM=0; 	#Numero de metricas a procesar
my $NU=0;	#Numero de metricas a con respuesta=U

	# Resetea el vector OID2TXT, lo rellena con los datos de la BBDD y genera
	# el fichero de cache junto con su firma.
	my $map_md5=$self->reset_mapping();

	my $log_level=$self->log_level();
	my $FXM=Crawler::FXM::Plugin->new(log_level=>$log_level, 'snmp'=>$self);
	$self->fxm($FXM);
	$self->init_tmark();
	#my $sanity_lapse = $Crawler::SANITY_LAPSE + int(rand(3600));
	my $sanity_lapse = $Crawler::SANITY_LAPSE + int(rand(43200)); #+12h

   #Ajustes de real_lapse
	my $real_lapse = $self->real_lapse($lapse);

   while (1) {

      %DATA_DIFF=();
		$self->clear_cache();

		my $ts=time;
		$self->sanity_check($ts,$range,$sanity_lapse);

		my $store=$self->store();
		my $dbh=$self->dbh();

      # -----------------------------------------------------------------------
		# Chequeo si ha cambiado el mappind de oid->oidn (metricas snmp clase2)
		if ( $self->check_mapping($map_md5)) { $map_md5=$self->reset_mapping();  }

      # -----------------------------------------------------------------------
		# Si no hay link, no se ejecutan las tareas
		my @task=();
		my $if=my_if();
      my $link_error=$self->check_if_link($if);
		if ($link_error <= 0) {
	      my $rx = $store->get_crawler_task_from_work_file($range,'snmp',\@task);
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
		$self->log('info',"do_task::[INFO] -R- snmp.$lapse|IDX=$range|NM=$NM [rrd=$a alert=$b db=$c] LINK_ERROR=$link_error");

      my $tnext=$ts+$real_lapse;

		$self->init_cache_oids(\@task);

		$NU=0;
		%U=();
		my $nt=0;
      foreach my $desc (@task) {

			$desc->{'lapse'}=$lapse;
         my $task_name=$desc->{'module'};
			my $task_id=$desc->{'host_ip'}.'-'.$desc->{'name'};
			$self->task_id($task_id);

	      if ($desc->{'version'}==3) {

            my @p=split(';',$desc->{'credentials'});
            $desc->{'sec_name'}=$p[1];
            $desc->{'sec_level'}=$p[2];
				if ($p[3] eq 'null') { $p[3]=''; }
            $desc->{'auth_proto'}=$p[3];
            $desc->{'auth_pass'}=$p[4];
				if ($p[5] eq 'null') { $p[5]=''; }
            $desc->{'priv_proto'}=$p[5];
            $desc->{'priv_pass'}=$p[6];
      	}

#DBG--
         if ($desc->{'version'}==3) {
				$self->log('debug',"do_task::[DEBUG] *** TAREA=$task_id ($task_name) sec_name=@{[$desc->{sec_name}]} sec_level=@{[$desc->{sec_level}]}  auth_proto=@{[$desc->{auth_proto}]}  version=@{[$desc->{version}]} oid=@{[$desc->{oid}]} WATCH=$desc->{watch} credentials=@{[$desc->{credentials}]}" );
         }
         else {
            $self->log('debug',"do_task::[DEBUG] *** TAREA=$task_id ($task_name) @{[$desc->{community}]} @{[$desc->{version}]} @{[$desc->{oid}]} WATCH=$desc->{watch}" );
         }
#/DBG--

#fml
my $rx=$self->response();
$self->log('debug',"do_task::[DEBUG ID=$task_id] RESPONSE INICIAL=$rx");

         #----------------------------------------------------
		   my $ip=$desc->{'host_ip'};
   		if (! exists $SNMP_CACHE{$ip}) {
				my $oid_pre=$desc->{oid};
      		my ($rc,$rcstr,$res)=$self->verify_snmp_data_lite($desc);
				$desc->{oid}=$oid_pre;
     			$SNMP_CACHE{$ip}=[$rc,$rcstr,$res];
#fml
my $rx=$self->response();
$self->log('debug',"do_task::[DEBUG ID=$task_id] CAMBIO RESPONSE =$rx");

   		}

			my $tp1=Time::HiRes::time();
         #----------------------------------------------------
			my ($rv,$ev)=$self->modules_supported($desc);
			if ((defined $rv->[0]) && ($rv->[0] eq 'U')) {
				$NU+=1;
				my $ip=$desc->{'host_ip'};
				$U{$ip}=1;
			}
         #----------------------------------------------------
			$nt += 1;
         my $tpdiffx=Time::HiRes::time()-$tp1;
         my $tpdiff=sprintf("%.3f", $tpdiffx);
        	$self->log('debug',"do_task::**PROFILE** [$nt|$NM|LAPSE=$tpdiff] TAREA=$task_id @{[$desc->{oid}]} [@$rv] WATCH=$desc->{watch}" );


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
         my $f=$ts.'-snmp-'.$lapse.'-'.$mode_subtype_subtable.'-'.$range;
         my $ftemp='.'.$f;


	      my $output_dir="$Crawler::MDATA_PATH/output/$cid/m";
  		   if (! -d $output_dir) {
         	mkdir "$Crawler::MDATA_PATH/output";
	         mkdir "$Crawler::MDATA_PATH/output/$cid";
   	      mkdir $output_dir;
      	}
			
			my $fh;
         open ($fh, ">", "$output_dir/$ftemp");
         foreach my $d (@{$DATA_DIFF{$cid_mode_subtype_subtable}}) {
            print $fh $d->{'iddev'}.';',$d->{'iid'}.';'.$d->{'data'}."\n";
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
			$self->log('warning',"do_task::[WARN] *S* snmp.$lapse|$real_lapse|IDX=$range|NM=$NM|NU=$NU|WAIT=$wait");
      }
      else {

         $self->log('info',"do_task::[INFO] -W- snmp.$lapse|$real_lapse|IDX=$range|NM=$NM|NU=$NU|WAIT=$wait");
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
#
#   # Resetea el vector OID2TXT, lo rellena con los datos de la BBDD y genera
#   # el fichero de cache junto con su firma.
#   my $map_md5=$self->reset_mapping();
#
#   my $tdisp=TDispatch->new( num_threads => 1);
#   $self->tdisp($tdisp);
#   my $slice_size = $SLICE_SIZE_VECTOR{$lapse} || 120;
#
#   while (1) {
#
#         $self->log('info',"do_task::#**do_task_th $range**");
#      #OJO el cache se debe manejar a nivel de thread
#      #$self->clear_cache();
#
#      my $store=$self->store();
#      my $dbh=$self->dbh();
#
#      # Chequeo si ha cambiado el mappind de oid->oidn (metricas snmp clase2)
#      if ( $self->check_mapping($map_md5)) { $map_md5=$self->reset_mapping();  }
#
#      # Control de cambios --------------------------------------------------
#      # Al arrancar el crawler reload siempre es = 1 porque el atributo sign = 0.
#      my $reload=$self->get_file_idx($range,\@task);
#      if ($reload) {
#         $self->log('info',"do_task::#RELOAD **reload $range**");
#         my $rv=$store->get_crawler_task_from_file($range,\@task);
#         if (!defined $rv) {
#            #En este caso hago la tarea que estuviera contenida en el vector @task
#            $self->log('warning',"do_task::#RELOAD[WARN] Tarea no definida");
#         }
#      }
#      $NM=scalar @task;
#      $self->log('info',"do_task::[INFO] -R- snmp.$lapse|IDX=$range|NM=$NM");
#
#      my $tnext=time+$lapse;
#
#      $NU=0;
#      %U=();
#
#      #----------------------------------------
#      # MODE:
#      # 1: Thread slices ==> @task -> N slices -> Nthreads
#      # 2: Standalone    ==> @task en bloque -> 1 proceso
#      #my $tdisp=$self->tdisp();
#      #$tdisp->slice_vector(\@task,$slice_size,'iddev');
#      #$tdisp->tdispatcher(\&do_sub_task,$self);
#
#      $self->do_sub_task(0,0,\@task);
#
#      #----------------------------------------------------
#      if ($Crawler::TERMINATE == 1) {
#         $self->log('info',"do_task::[INFO] ***SIGTERM*** Terminamos recibida signal ...");
#         exit 0;
#      }
#      my $wait = $tnext - time;
#      if ($wait < 0) {
#         $self->log('warning',"do_task::[WARN] *S* snmp.$lapse|IDX=$range|NM=$NM|NU=$NU|WAIT=$wait");
#      }
#      else {
#
#         $self->log('info',"do_task::[INFO] -W- snmp.$lapse|IDX=$range|NM=$NM|NU=$NU|WAIT=$wait");
#         sleep $wait;
#      }
#      #----------------------------------------------------
#      if ($Crawler::TERMINATE == 1) {
#         $self->log('info',"do_task::[INFO] ***SIGTERM*** Terminamos recibida signal ...");
#         exit 0;
#      }
#
#      #if ($descriptor->{once}) {exit;}
#   }
#}


##----------------------------------------------------------------------------
# Funcion: modules_supported
# Descripcion:
#----------------------------------------------------------------------------
sub modules_supported  {
my ($self,$desc)=@_;
my $rv=[];
my $ev=[];

	my $module=$desc->{'module'};
   my $task_id=$desc->{'host_ip'}.'-'.$desc->{'name'};
   $self->task_id($task_id);

#eval {

	@EVENT_DATA=();
	$self->event_data([]);

	# Por defecto $MITEMS es el numero de oids
	my @o=split(/\|/,$desc->{oid});
	$MITEMS = scalar (@o);

	$desc->{ext_params}='';

	if ($module =~ /mod_snmp_get_ext\:(\S+)/i) {
   	$desc->{ext_function}=$1;
		if ($desc->{ext_function} =~ /ext_fx\((.+)\)/) {
   		$desc->{ext_function}='ext_fx';
			$desc->{ext_params}=$1;
		}
      ($rv,$ev)=$self->mod_snmp_get_ext($desc);
   }

   elsif ($module =~ /mod_snmp_get/i) { ($rv,$ev)=$self->mod_snmp_get($desc);}

   elsif ($module =~ /mod_snmp_walk\:*(.*)$/i) {
		$desc->{ext_function}=$1;

		#$self->log('debug',"modules_supported::[DEBUG] module=$module extf=$desc->{ext_function}**fml");

		($rv,$ev)=$self->mod_snmp_walk($desc);

	}

   else {$self->log('warning',"modules_supported::[WARN] No definid o modulo: $module"); }

	return ($rv,$ev);

#};
#if ($@) { $self->log('warning',"modules_supported::[WARN] Error $@ en modulo=$module"); }

}


#----------------------------------------------------------------------------
# Funcion: verify_snmp_data
# Descripcion:
#	Verifica si el dispositivo responde por SNMP. Para ello obtiene los valores
#	de sysdescr, sysoid, sysname y sysloaction.
#	Tambien obtiene el id de enterprise a partir de sysoid
#	Es llamada desde otros metodos de la clase (do_task, chk_metric, get_snmp_version)
#	y tambien desde el alert_manager de la clase Notifications.
#
# OUT: ($rc, $rcstr,$res)
#
#	$rc: Codigo de retorno 0->OK, !=0->NOK
#	$rcstr: Mensaje de error
#	$res:	Resultado (core_snmp_table). Es un array del tipo:
#
#		v1:@:v2:@:v3....vn
#		v1:@:v2:@:v3....vn
#		v1:@:v2:@:v3....vn
#
# Los resultados se incluyen como claves del hash $desc de entrada por lo que
# se podria prescindir de los valores de $res
#----------------------------------------------------------------------------
sub verify_snmp_data  {
my ($self,$desc)=@_;

   my $rc=0;
   my $rcstr='';
	my $res=[];

	#sysname
   $desc->{'oid'} = '.1.3.6.1.2.1.1.5.0';
   my $r=$self->core_snmp_get($desc);
	$desc->{'sysname'} = ($r->[0] eq 'U') ? '** sin respuesta snmp **' : $r->[0];
	$rc=$self->err_num();
	$rcstr=$self->err_str();
	
	if ($rc !=0) {
		
		$desc->{'sysname'} = "$rcstr ($rc)";
		#sysoid
	   $desc->{'oid'} = '.1.3.6.1.2.1.1.2.0';
   	$r=$self->core_snmp_get($desc);
   	$desc->{'sysoid'} = ($r->[0] eq 'U') ? '** sin respuesta snmp **' : $r->[0];
	   $rc=$self->err_num();
   	$rcstr=$self->err_str();
		# Si no responde a sysname ni sysoid termina con resultado
		# de sin respuesta SNMP
		if ($rc !=0) { 	return ($rc, $rcstr,$res); 	}
	}
	else {
		#sysoid
	   $desc->{'oid'} = '.1.3.6.1.2.1.1.2.0';
   	$r=$self->core_snmp_get($desc);
   	$desc->{'sysoid'} = $r->[0];
	}

	#sysdesc
   $desc->{'oid'} = '.1.3.6.1.2.1.1.1.0';
   $r=$self->core_snmp_get($desc);
	$desc->{'sysdesc'} = $r->[0];

	#sysloc
   $desc->{'oid'} = '.1.3.6.1.2.1.1.6.0';
   $r=$self->core_snmp_get($desc);
	$desc->{'sysloc'} = $r->[0];

	#$desc->{'enterprise'}=$self->snmp_get_enterprise($desc->{'sysoid'});
	
	my %enterprises_supported=();
	my $ent_base=$self->snmp_get_enterprise($desc->{'sysoid'});
	$enterprises_supported{$ent_base}=1;

	# --------------------------------------------------------------
	# CHEQUEOS EMPIRICOS
	# --------------------------------------------------------------
	if ( exists $Enterprises::ENTERPRISE_CHECKS{$ent_base}) {
		foreach my $h (@{$Enterprises::ENTERPRISE_CHECKS{$ent_base}}) {
			$desc->{'oid'} = $h->{'oid'};
	      $r=$self->core_snmp_get($desc);
   	   my $rce=$self->err_num();
      	#if ($rce == 0) { push @enterprises_supported, $h->{'enterprise'}; }
      	if ($rce == 0) { $enterprises_supported{$h->{'enterprise'}} = 1; }
			$self->log('info',"verify_snmp_data:: ent_base=$ent_base check=$h->{enterprise} RES=$rce (0=SI)");
		}
	}

	# --------------------------------------------------------------
   $desc->{'oid'}='SNMPv2-MIB::sysORTable';
	my $timeout_max=10;
   my $sysORTable=$self->core_snmp_table_hash($desc,$timeout_max);
   foreach my $x (keys %$sysORTable) {
      if (exists $sysORTable->{$x}->{'sysORID'}) {
      	#my $oid=SNMP::translateObj($sysORTable->{$x}->{'sysORID'});
      	if ($sysORTable->{$x}->{'sysORID'} =~ /1\.3\.6\.1\.4\.1\.(\d+)/) { $enterprises_supported{$1} = 1; }
		}
	}


	$desc->{'enterprise'}=join(",", keys %enterprises_supported);
	# --------------------------------------------------------------

	$res=[ join(':@:',0,$desc->{'sysdesc'}, $desc->{'sysoid'}, $desc->{'sysname'}, $desc->{'sysloc'}, $desc->{'enterprise'}) ];
   return ($rc, $rcstr,$res);
}


#----------------------------------------------------------------------------
# verify_snmp_data_lite
# Version sencilla de verify_snmp_data. Solo valida si responde a snmp en base
# al sysname y sysoid
#----------------------------------------------------------------------------
sub verify_snmp_data_lite  {
my ($self,$desc)=@_;

   my $host=$desc->{host_ip};
   my $community=$desc->{community};
   my $version= (defined $desc->{version}) ? $desc->{version} : 1;
   my $auth_proto = (defined $desc->{'auth_proto'}) ? $desc->{'auth_proto'} : 'MD5' ;
   my $auth_pass = (defined $desc->{'auth_pass'}) ? $desc->{'auth_pass'} : '' ;
   my $priv_proto = (defined $desc->{'priv_proto'}) ? $desc->{'priv_proto'} : 'DES' ;
   my $priv_pass = (defined $desc->{'priv_pass'}) ? $desc->{'priv_pass'} : '' ;
   my $sec_name = (defined $desc->{'sec_name'}) ? $desc->{'sec_name'} : '' ;
   my $sec_level = (defined $desc->{'sec_level'}) ? $desc->{'sec_level'} : '' ;
	my $timeout=$self->timeout();
	if ($timeout<3000000) { $timeout=3000000; }

   if ($version == 3) {
      if ($sec_level =~ /authnopriv/i) {$sec_level='authNoPriv';}
      elsif ($sec_level =~ /authpriv/i) {$sec_level='authPriv';}
      elsif ($sec_level =~ /noauthnopriv/i) {$sec_level='noAuthNoPriv';}
   }

$self->log('debug',"verify_snmp_data_lite::[**FML**] ip=$host STEP 1 version=$version sec_name=$sec_name sec_level=$sec_level auth_proto=$auth_proto auth_pass=$auth_pass priv_proto=$priv_proto priv_pass=$priv_pass");

	my $EngineTime=time();
   my $sess = new SNMP::Session( DestHost => $host, Community => $community, Version=>$version, Timeout=>$timeout, Retries=>'2',
                                 SecName=>$sec_name, SecLevel=>$sec_level, 'EngineTime'=>$EngineTime,
                                 AuthProto=>$auth_proto, AuthPass=>$auth_pass, PrivProto=>$priv_proto, PrivPass=>$priv_pass);


	my ($rc, $rcstr,$res) = ('1','ERROR (SIN SESION)',[]);
	if (! defined $sess) { 	
		$self->response('NOSNMP');
		$self->log('info',"verify_snmp_data_lite:: **NOSNMP** ip=$host version=$version community=$community sec_name=$sec_name sec_level=$sec_level auth_proto=$auth_proto auth_pass=$auth_pass priv_proto=$priv_proto priv_pass=$priv_pass rc=$rc ($rcstr)");
		return ($rc, $rcstr,$res);  
	}


$self->log('debug',"verify_snmp_data_lite::[**FML**] ip=$host (timeout=$timeout) STEP 2");

	my $val = $sess->get('.1.3.6.1.2.1.1.1.0');
	if (! defined $val) { $val = 'U'; }

	$rc=$sess->{ErrorNum};
	$rcstr=$sess->{ErrorStr};
$self->log('debug',"verify_snmp_data_lite::[**FML**] ip=$host STEP 3 rc=$rc rcstr=$rcstr val=$val");
	#-24:Timeout
	if ($rc==-24) { $self->response('NOSNMP'); }
	#-35:Authentication failure (incorrect password, community or key)
	elsif ($rc==-35) { $self->response('NOSNMP'); }
	#-33:Unknown user name
	elsif ($rc==-33) { $self->response('NOSNMP'); }
   #16:authorizationError (access denied to that object)
 	elsif ($rc==16) { $self->response('NOSNMP'); }
	else {
		if ($rc != 0) {
		   $self->log('info',"verify_snmp_data_lite:: **MIRAR RC** ip=$host version=$version community=$community sec_name=$sec_name sec_level=$sec_level auth_proto=$auth_proto auth_pass=$auth_pass priv_proto=$priv_proto priv_pass=$priv_pass rc=$rc ($rcstr) val=$val");
		}
		$self->response('OK');
		$rc=0;
		$res=[$val];
	}

	if ($self->response() eq 'NOSNMP') {
	   $self->log('info',"verify_snmp_data_lite:: **NOSNMP** ip=$host version=$version community=$community sec_name=$sec_name sec_level=$sec_level auth_proto=$auth_proto auth_pass=$auth_pass priv_proto=$priv_proto priv_pass=$priv_pass rc=$rc ($rcstr) val=$val");
	}

   return ($rc, $rcstr,$res);
}


#----------------------------------------------------------------------------
# snmp_mib2_system
# Obtiene los datos relevantes de un dispositivo por SNMP y los incluye en
# el hash de parametros para luegoporder actualizar la tabla devices.
# Los datos son:
#  $SNMPCFG{'sysdesc'}
#  $SNMPCFG{'sysoid'}
#  $SNMPCFG{'sysname'}
#  $SNMPCFG{'sysloc'}
#  $SNMPCFG{'enterprise'}
#  $SNMPCFG{'oid'}
#	$SNMPCFG{'mac'};
#	$SNMPCFG{'mac_vendor'};
#	$SNMPCFG{'netmask'};
#	$SNMPCFG{'network'};
#	$SNMPCFG{'switch'};
#
# OUT: ($rc, $rcstr)
#
#  $rc: Codigo de retorno 0->OK (Responde por SNMP) , !=0->NOK (No respondepor SNMP)
#  $rcstr: Mensaje de error
#
#----------------------------------------------------------------------------
sub snmp_mib2_system  {
my ($self,$desc)=@_;


   $desc->{'sysdesc'} = '** sin respuesta snmp **';
   $desc->{'sysoid'} = '** sin respuesta snmp **';
   $desc->{'sysname'} = '** sin respuesta snmp **';
   $desc->{'sysloc'} = '** sin respuesta snmp **';
   $desc->{'enterprise'} = 0;
   $desc->{'oid'}=$desc->{'sysoid'};

   #---------------------------------------------------------------
	# sysdesc,sysoid,sysname,sysloc,enterprise,oid
   my ($rc, $rcstr, $res)=$self->verify_snmp_data($desc);
	if ($rc !=0) { return ($rc, $rcstr); }

	$SIG{ALRM} = sub { die "timeout en snmp_mib2_system" };

	eval {

		alarm(30);

	   $self->snmp_prepare_info($desc);

   	#---------------------------------------------------------------
		# mac,mac_vendor
   	($desc->{'mac'},$desc->{'mac_vendor'}) = $self->snmp_get_mac($desc, $desc->{'host_ip'});

   	#---------------------------------------------------------------
		# netmask,network
   	$desc->{'netmask'} = $self->snmp_get_netmask($desc, $desc->{'host_ip'});
		if (defined $desc->{'netmask'}) {
		   my $nip =  NetAddr::IP->new($desc->{'host_ip'}, $desc->{'netmask'});
	   	$desc->{'network'} = (defined $nip) ? $nip->network() : '';
		}
		else {
   	#if ($desc->{'network'} eq ''){

	   	my $store=$self->store();
   		if ($store eq '') {
      		$self->create_store();
      		$store=$self->store();
   		}

	   	my $dbh=$self->dbh();
   		if (!defined $dbh ) {
      		$dbh=$store->open_db();
      		$self->dbh($dbh);
   		}	

      	my $networks = $store->get_cfg_networks($dbh,{});
      	my %IPS=();
      	foreach my $net (@$networks) {
         	if ( $net !~ /(\d+\.\d+\.\d+\.\d+)\/(\d+)/) { next; }
         	# Solo busco hosts en subredes clase B o inferiores (con menos hosts)
         	if ($2 < 16) { next; }
         	my $range=NetAddr::IP->new($net);
         	foreach my $ip (@$range) {
            	if ( $ip=~s/(\d+\.\d+\.\d+\.\d+)\/32/$1/) { $IPS{$ip}=$net; }
         	}
      	}

	      if (exists $IPS{$desc->{'host_ip'}}) { $desc->{'network'} = $IPS{$desc->{'host_ip'}}; }
   	}

   	#---------------------------------------------------------------
		# switch
   	my $switch_ports = $self->snmp_get_bridge_ports($desc, $desc->{'host_ip'});
   	$desc->{'switch'} = (defined $switch_ports) ? 1 : 0;

		alarm(0);
	};

	if ($@) { $rcstr .= 'Timeout en partes de la MIB'; }

	return ($rc, $rcstr);
}



#-------------------------------------------------------------------------------------------
# Funcion: chk_metric
# Descripcion:
#		Valida una determinada metrica SNMP, del tipo que sea (en modules_supported)
#		Valida un monitor aplicado sobre una metrica SNMP
#		Valida el caso especial de sin respuesta snmp (mon_snmp)
#
# IN:
#
#	1. $in es una ref a hash con los datos necesarios para identificar metrica+dispositivo.
#		Hay 2 opciones (mejor la a.):
#        a. $in->{'host_ip'} && $in->{'mname'}. Valida a partir de la ip y el nombre de la metrica en cuestion
#        b. $in->{'id_dev'} && $in->{'id_metric'}. Valida a partir del id del device y del id de la metrica en cuestion.
#		El resto de datos se obtienen de la tbla cfg_monitor_snmp
#
# OUT:
#     1. El parametro $results es una ref a un array pare guardar los resultados
#		2. El valor de retorno es 0->Sin alerta/1->Con alerta
#		3. El metodo event_data debe contener el evento que ha generado alerta para que notificationsd
#			acceda a dicha info.
#		4. El metodo severity debe contener la severidad de la alerta en caso de que el retorno sea 1.
#-------------------------------------------------------------------------------------------
#mysql> select id_device,id_alert_type,counter,mname,watch,type from alerts order by id_alert;
#+-----------+---------------+---------+------------------------+------------------------+------+
#| id_device | id_alert_type | counter | mname                  | watch                  | type |
#+-----------+---------------+---------+------------------------+------------------------+------+
#|        88 |             0 |       7 | novell_nw_disk_usage-1 | novell_nw_disk_usage-1 | snmp |
#|       338 |             0 |    1236 | mon_snmp               |                        | snmp |
#|       168 |          2084 |     728 | disk_mibhost-16        | s_disk_mibhost_2084    | snmp |
#|        27 |          2084 |     729 | disk_mibhost-13        | s_disk_mibhost_2084    | snmp |
#+-----------+---------------+---------+------------------------+------------------------+------+
sub chk_metric {
my ($self,$in,$results,$store)=@_;

#   #my $store=$self->create_store();
#   my $store=$self->store();
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

   my $lang = $self->core_i18n_global();
   $self->lang($lang);

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
         $results= [ $lang->{_errornodata} ];
         return 0;
      }
   }


   #--------------------------------------------------------------------------------------
	# Caso especial SIN RESPUESTA SNMP (mon_snmp)
   #--------------------------------------------------------------------------------------
	if ($mname eq 'mon_snmp') {
	   my $rres1=$store->get_from_db( $dbh, 'd.community,d.version', 'devices d', "d.ip=\'$ip\'");

	   my %desc1=();
   	$desc1{'host_ip'}=$ip;
   	$desc1{'community'}=$rres1->[0][0];
   	$desc1{'version'}=$rres1->[0][1];
	   if ($desc1{'version'}==3) {
   	   my $id_profile=$desc1{'community'};
      	my $v3 = $store->get_profiles_snmpv3($dbh,[$id_profile]);
      	$desc1{'sec_name'}=$v3->{$id_profile}->{'sec_name'};
      	$desc1{'sec_level'}=$v3->{$id_profile}->{'sec_level'};
      	$desc1{'auth_proto'}=$v3->{$id_profile}->{'auth_proto'};
      	$desc1{'auth_pass'}=$v3->{$id_profile}->{'auth_pass'};
      	$desc1{'priv_proto'}=$v3->{$id_profile}->{'priv_proto'};
      	$desc1{'priv_pass'}=$v3->{$id_profile}->{'priv_pass'};

			$self->log('debug',"chk_metric::[DEBUG] id_profile=$id_profile sec_name=$desc1{'sec_name'}");
   	}

  		my ($rc1,$rcstr1,$res1)=$self->verify_snmp_data_lite(\%desc1);

#DBG--
      $self->log('debug',"chk_metric::[DEBUG] **RC=$rc1 RCSTR1=$rcstr1 RES1=@$res1");
#/DBG--

		my $display_txt = $lang->{'_result'}.':';
		if ($rc1 != 0) {
			my $data_out1= $lang->{'_sinrespuestasnmp'}." ($rcstr1)";
			$self->event_data([$data_out1]);
   		push @$results, [$display_txt, $data_out1];
         $self->severity(2);
			$self->data_out(['U']);
		}
   	else {
			my $data_out1="@$res1\n";   	
			$self->data_out($res1);
   		push @$results, [$display_txt, $data_out1];
		}
		return 0;
#   	if ($rc1 != 0) {
#			$self->severity(1);
#			return 1;
#		}
#		else {  return 0;  }
	}


   #--------------------------------------------------------------------------------------
   # El parametro de entrada es mname (metrica instanciada) pero en la consulta de cfg_monitor_wbem necesitamos el subtype
   # Si cfg=1 (sin iids) => subtype = mname
   # Si cfg=2 (con iids) => subtype = mname sin la info de iids
   #--------------------------------------------------------------------------------------
   my $subtype=$mname;
   my $iid=undef;
	#cpq_da_log_status-3.2 (el iid puede tener caracteres no alfanumericos)
   if ($mname =~ /(.*?)-(\S+)$/) {
      $subtype=$1;
      $iid=$2;
   }


   #--------------------------------------------------------------------------------------
   my $log_level=$self->log_level();
   my $FXM=Crawler::FXM::Plugin->new(log_level=>$log_level, 'snmp'=>$self);
	$FXM->subtype($subtype);
   $self->fxm($FXM);


   #--------------------------------------------------------------------------------------
   my $rres=$store->get_from_db( $dbh, 'c.oid,d.community,d.version,c.descr,c.items,c.module,c.get_iid,c.oidn,c.cfg,c.severity,c.mode,d.id_dev,c.esp,c.params', 'cfg_monitor_snmp c, devices d', "c.subtype=\'$subtype\' and d.ip=\'$ip\'");
   #my $rres=$store->get_from_db( $dbh, 'c.oid,d.community,d.version,c.descr,c.items,c.module,c.get_iid,c.oidn,c.cfg,c.severity,c.mode,d.id_dev,m.file', 'cfg_monitor_snmp c, devices d, metrics m', " m.id_dev=d.id_dev and m.name=\'$mname\' and c.subtype=\'$subtype\' and d.ip=\'$ip\'");
   #--------------------------------------------------------------------------------------

   my %desc=();
   $desc{'host_ip'}=$ip;
   $desc{'name'}=$mname;
   $desc{'oid'}=$rres->[0][0];
   $desc{'community'}=$rres->[0][1];
   $desc{'version'}=$rres->[0][2];
   my $DESCR=$rres->[0][3];
   my $items=$rres->[0][4];
   $desc{'module'}=$rres->[0][5];
   $desc{'get_iid'}=$rres->[0][6];
   $desc{'oidn'}=$rres->[0][7];
	$desc{'cfg'}=$rres->[0][8];
	my $severity=$rres->[0][9];
	my $mode=$rres->[0][10];
	$desc{'mode'}=$rres->[0][10];
	my $id_dev=$rres->[0][11];
	$desc{'esp'}=$rres->[0][12];
	$desc{'params'}=$rres->[0][13];
	$desc{'subtype'}=$subtype;


	# Parche para metricas snmp con cfg=2 (tipo tabla)
	# En este caso, no tienen iid asignado
	if ($desc{'cfg'}==2) {

		my $oidnX='';
		# El caso de traffic_mibii_if-xx es particular porque el OID instanciado puede ser el correspondiente
		# a ifTable o ifXTable y en la definicion de la metrica en cfg_monitor_snmp solo aparece el relativo 
		# a ifTable. El extendido se asigna de forma dinamica y transparente`para el usuario.
		if ((exists $desc{'name'}) && ($desc{'name'}=~/traffic_mibii_if-(\d+)/)) {
		#name=traffic_mibii_if-36
			my $nx=$desc{'name'};
			my $rres=$store->get_from_db( $dbh, 'r.oid', 'metric2snmp r, metrics m, devices d', "m.id_dev=d.id_dev AND m.id_metric=r.id_metric AND m.name='$nx' AND d.ip='$ip'");
			if ($rres->[0][0]=~/\.1\.3\.6\.1\.2\.1\.31/) { $oidnX='ifHCInOctets_ifHCOutOctets'; }
		}
		if ($oidnX ne '') { 
			$desc{'oid'} = $oidnX;
			$desc{'oidn'}='ifHCInOctets.'.$iid.'|'.'ifHCOutOctets.'.$iid;
		}
		else {

			$desc{'oid'}=$desc{'oidn'};
			$desc{'oid'} =~ s/\.IID//g;
			$desc{'oid'} =~ s/\|/_/g;
			if (! defined $iid) {
   			$desc{'module'}='mod_snmp_walk';
			}
			else { $desc{'oidn'}=~s/\.IID/\.$iid/g; }
		}

		$self->log('debug',"chk_metric::[***DEBUG] cfg=2 oidnX=$oidnX oid=$desc{'oid'} iid=$iid name=$desc{'name'} module=$desc{'module'}");
	}


	#----------------------------------------------------
	if ($desc{'version'}==3) {
  		my $id_profile=$desc{'community'};
      my $v3 = $store->get_profiles_snmpv3($dbh,[$id_profile]);
      $desc{'sec_name'}=$v3->{$id_profile}->{'sec_name'};
      $desc{'sec_level'}=$v3->{$id_profile}->{'sec_level'};
      $desc{'auth_proto'}=$v3->{$id_profile}->{'auth_proto'};
      $desc{'auth_pass'}=$v3->{$id_profile}->{'auth_pass'};
      $desc{'priv_proto'}=$v3->{$id_profile}->{'priv_proto'};
      $desc{'priv_pass'}=$v3->{$id_profile}->{'priv_pass'};
	}


	#----------------------------------------------------
	# Solo si la metrica esta asociada al dispositivo obtendremos un resultado de esta query.
   my $rres1=$store->get_from_db( $dbh, 'm.file,m.label,m.file,m.c_label', 'metrics m, devices d', "m.id_dev=d.id_dev and  d.ip=\'$ip\' and  m.name=\'$mname\'");
   my $file=$rres1->[0][0] || '';
   my $label=$rres1->[0][1] || '';
	$desc{'file'}=$rres1->[0][2];
   my $c_label=$rres1->[0][3] || '';
   $label =~ s/^(.*?)\(\S+\)$/$1/;  #Obviamos la parte de (host_name)
	
#print "VALIDANDO [ip=$desc{host_ip} mname=$mname] [oid=$desc{oid} c=$desc{community} v=$desc{version} module=$desc{module}]\n";

   #--------------------------------------------------------------------------------------
	my $display_txt = $lang->{'_metric'}.' ('.$mode.'):';
	my $display_txt2 = '';
   push @$results, [$display_txt,"$DESCR ($label)",''];
	$display_txt = $lang->{'_monitoredvalues'}.':';
   push @$results, [$display_txt, $items, ''];
   push @$results, [$display_txt, $desc{'oidn'}, ''];
   push @$results, ['fx:', $desc{'esp'}, ''];
#   push @$results, ['Parametros:', $desc{'params'}, ''];

   my ($rv,$ev)=$self->modules_supported(\%desc);

   my $rc=$self->err_num();
   my $rcstr=$self->err_str();

	my $strange=0;
	if (! defined $rv) {
		$rv=['U'];
		$rc=1;
		$strange=1;
	}
	#Esta linea no deberia ser necesaria
	elsif ( ($rv->[0] eq 'U') && ($rc == 0) ) { $rc=1; $rcstr='U'; }


	$self->event_data($ev);
	$self->data_out($rv);

$self->log('info',"chk_metric::[DEBUG] **FML** *modules_supported rv=@$rv ev=@$ev RC=$rc RCSTR=$rcstr mode=$mode mname=$mname subtype=$subtype ip=$ip*** cfg=$desc{cfg} file=$file");
#   my $rc=$self->err_num();
#   my $rcstr=$self->err_str();
#	if ($rv->[0] eq 'U') { $rc=1; }

#	if ($desc{'cfg'}==2) {
#		$rv->[0] =~ s/\:@\:/  /g;
#		$rv->[0] =~ s/\:/<br>/g;
#	}


	my $params = $self->get_metric_params(\%desc);

	my $data_out='';
	my $skip_watch=0;
	my $fpath='/opt/data/rrd/elements/'.$file;

	if (($mode eq 'GAUGE') || (exists $in->{'only_value'})){
	   if ($rc != 0) {
			$data_out = "sin datos OID para ($label) ($rcstr)";
			$desc{oid}=~ s/[_|\|]/  /g;	# Es estetico, pero al no haber espacios se descontrola el ancho de los eventos
			if ($strange) { $self->event_data(["sin datos OID para ($label) ($rcstr) (G) **REVISAR METRICA**"]); }
			else {  $self->event_data(["sin datos OID para ($label) ($rcstr) (G)"]); }
		}
		else { $data_out="@$rv\n";  }

   	#if (scalar @$ev > 0) { $data_out .= "(@$ev)";  }
   	#push @$results, ['Datos dispositivo:', $data_out ];
		# Si la metrica no es tabla (escalar o especial??)
		if ($desc{'cfg'}!=2) {
			#if (scalar @$ev > 0) { $data_out .= "(@$ev)";  }
			$display_txt = $lang->{'_devicedata'}.':';
			push @$results, [$display_txt, $data_out ];
		}
		# Si la metrica es tabla pero ya esta instanciada
		elsif ( $mname ne $subtype) { 
			$display_txt = $lang->{'_devicedata'}.':';
			push @$results, [$display_txt, $data_out ]; 
		}
		elsif ( $desc{'esp'} =~ /TABLE/) { 
			$display_txt = $lang->{'_devicedata'}.':';
			push @$results, [$display_txt, $data_out ]; 
		}
		else {
			foreach my $r (@$rv) {

				$self->log('debug',"chk_metric:: Datos dispositivo r=$r----");
				my @d=split(/\:\@\:/, $r);
				my $iid=shift(@d);
				if ((exists $params->{'iid_mode'}) && ($params->{'iid_mode'} =~ /ascii/i)) {
					my @parsed_iid = map { $_>=32 ? $_ : 32 } split(/\./,$iid);
					$iid = pack("C*", @parsed_iid);
				}

				$self->log('debug',"chk_metric:: Datos dispositivo iid=$iid >> @d");

				$display_txt = $lang->{'_devicedata'}.' [iid='.$iid.']:';
   			push @$results, [$display_txt,"@d",''];
			}	
		}
		if (scalar @$ev > 0) { 
			$display_txt = $lang->{'_devicedata'}.' [Ev]:';
			push @$results, [$display_txt,"@$ev",'']; 
		}
	}

   #--------------------------------------------------------------------------------------
   # Hay que contemplar el caso de las metricas diferenciales (counter), porque el watch hay
	# que evaluarlo sobre la diferencia, no sobre el valor absoluto
   #elsif (($mode eq 'COUNTER') && ($desc{'esp'} ne '')) {
	elsif (($mode eq 'COUNTER')) {

      my $rvd=undef;
      if ( ($file) && (-f $fpath))  {
         $rvd=$store->fetch_rrd_last($file);
         if ($subtype eq 'traffic_mibii_if') {
            my @rvd8 = map { 8 * $_ } @$rvd;
$self->log('info',"chk_metric::[FML] **rvd8 = @rvd8**rvd= @$rvd");
            $rvd = \@rvd8;
         }
      }

      if ( (!defined $rvd) || (! exists $rvd->[0]) ) {
         $rvd = ['U'];
         $self->log('warning',"chk_metric::[WARN] **$desc{host_ip}:$mname MODE=COUNTER RV=UNDEF/SIN DATOS EN RRD FILE=$file**");
         $data_out = "sin datos OID $desc{oid} ($rcstr)";
         $desc{oid}=~ s/[_|\|]/  /g;  # Es estetico, pero al no haber espacios se descontrola el ancho de los eventos
         if ($strange) { $self->event_data(["sin datos OID $desc{oid} ($rcstr) (C) **REVISAR METRICA**"]); }
         else { $self->event_data(["sin datos OID $desc{oid} ($rcstr) (C)"]); }
         $rc=1;
#$self->log('warning',"chk_metric:: **FMLL**************************");

         foreach my $r (@$rv) {

            my @d=split(/\:\@\:/, $r);
            my $iid=shift(@d);
            if ((exists $params->{'iid_mode'}) && ($params->{'iid_mode'} =~ /ascii/i)) {
               my @parsed_iid = map { $_>=32 ? $_ : 32 } split(/\./,$iid);
               $iid = pack("C*", @parsed_iid);
            }

            $self->log('debug',"chk_metric:: Datos dispositivo iid=$iid >> @d");

				$display_txt = $lang->{'_devicedata'}.' [iid='.$iid.']:';
            push @$results, [$display_txt,"@d",''];
         }

			$display_txt = $lang->{'_differentialdata'}.':';
         push @$results, [$display_txt, $lang->{'_nodiffdata'}];
      }
#DBG--
      else {
         $self->log('debug',"chk_metric::[DEBUG] **$desc{host_ip}:$mname MODE=COUNTER [@$rvd] F=$file**");
         my $kkk=scalar @$rvd;
         my $kkk1=$rvd->[0];
         my $kkk2=$rvd->[1];
         $self->log('debug',"chk_metric::[DEBUG] **FML N=$kkk v1=$kkk1 v2=$kkk2**");
			$display_txt = $lang->{'_devicedata'}.':';
         push @$results, [$display_txt, "@$rv"];
			$display_txt = $lang->{'_differentialdata'}.':';
         push @$results, [$display_txt, "@$rvd"];

      }

#/DBG--
#		push @$results, ['Datos diferenciales:', "@$rvd"];
		#Para evaluar el watch
		$rv=$rvd;
   }
	# Caso de metrica diferencial pero que no existe el fichero. Puedo obtener el dato
	# pero no evaluda el watch
	else { $skip_watch=1; }

   #--------------------------------------------------------------------------------------
   # Si hay un error en la obtencion de datos, se termina. No tiene sentido evaluar watches
   # Se devuelve 0 porque no hay watch y se pone la severidad a minor.
   if ($rc != 0) {
      $severity=3;
      $self->severity($severity);
		$self->data_out(['U']);
		$self->log('warning',"chk_metric::[WARN] **$desc{host_ip}:$mname **ERROR AL OBTENER DATOS**");
      return 0;
   }

	#$self->log('warning',"chk_metric::[WARN] **$desc{host_ip}:$mname skip_watch=$skip_watch****esp= $desc{'esp'}");

	if ($skip_watch==1) { return 0; }

   #--------------------------------------------------------------------------------------
   # Miro si es necesario chequear un monitor asociado a dicha metrica. Solo en el caso en que:
   #  1. La metrica tenga monitor asociado (en alert_type)
   #  2. El monitor este asociado al dispositivo que se esta chequeando
   my $watch=$store->get_from_db( $dbh, 'a.cause,a.severity,a.expr,a.monitor,m.items,m.top_value', 'alert_type a, metrics m,devices d', "m.name=\'$mname\' and m.watch=a.monitor and m.id_dev=d.id_dev and d.ip=\'$ip\'");

#print "select a.cause,a.severity,a.expr from alert_type a, metrics m,devices d where mname='$mname' and m.watch=a.monitor and m.id_dev=d.id_dev and d.ip='$ip' <br>";

   foreach my $w (@$watch) {

		my $cause=$w->[0];
      my $severity=$w->[1];
      my $expr_long=$w->[2];
		my $watch_name=$w->[3];	
		#my $rvj = join (', ',@$rv);
		my @items = split (/\|/, $w->[4]);
		my $top_value=$w->[5];

		$ev->[0]=$label;
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
	      $self->log('debug',"chk_metric::[DEBUG ID=$task_id] **TEST WATCH (2) => $watch_name => $cause|$expr|$sev** expr_long=$expr_long");
#/DBG--

			if ($expr eq '') { next;}
			# Si el monitor es de analisis (STEP;v1+v2;5;TOUT) tengo que extraer la expresion.
			#my ($fx,$expr_orig)=('',$expr);
			#if ($expr=~/\s*;\s*/) {
			#	my @d = split (/\s*;\s*/, $expr);
			#	$expr=$d[1];
			#	$fx=$d[0];
			#}

      	my ($condition,$lval,$oper,$rval)=$self->watch_eval($expr,$rv,$file,{'top_value'=>$top_value});

			$display_txt = $lang->{'_monitorassociated'}.':';
	      push @$results, [$display_txt, "$cause ($expr) ($lval $oper $rval)",''];
   	   #if (($condition) && (! $fx)) {
   	   if ($condition) {
				$display_txt = $lang->{'_result'}.':';
				$display_txt2 = '**'.$lang->{'_alert'}."** ($lval $oper $rval)";
         	push @$results, [$display_txt, $display_txt2, ''];
	         #my $ev="$label ($rvj) **ALERTA ($expr) ($lval $oper $rval)**";
   	      #$self->event_data([$ev]);

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
			#	if (! $fx) { 	push @$results, ['Resultado Monitor:',"($rvj)",''];  }
			#	else { push @$results, ['Resultado Monitor:',"($rvj) **NO SE HA VERIFICADO LA FUNCION $fx**",''];  }
			#	return 0;
			#}
		}
		$display_txt = $lang->{'_result'}.':';
		$display_txt2 = $lang->{'_noalertbymonitor'};
		push @$results, [$display_txt,$display_txt2,''];
   }
	return 0;
}

#----------------------------------------------------------------------------
# Funcion: fill_cache
# Descripcion:
#  Rutina encargada de llenar el cache snmp para ganar eficiencia.
#  En el cache se uarda el valor obtenido de los oids. No se guardan los resultados
#  finales (items), eso ya se normaliza mediante las funcion ext o esp adecuada
#----------------------------------------------------------------------------
sub fill_cache  {
my ($self,$desc,$key)=@_;

	my $task_id=$self->task_id();
	#FML $iid deberia ser $desc->{'iid'} Pero posiblemente en las BBDD no este a nivel.
   my ($subtype,$iid)=split(/\-/,$desc->{'name'},2);
   $desc->{oid} = $self->_oid_prepare($desc->{oid});

	# oid es del tipo: ifHCInOctets_ifHCOutOctets
	my @o=split(/_/,$desc->{oid});
   my $num_values=scalar(@o);

   if (! defined $desc->{oid}) {
   	$self->log('warning',"fill_cache::[ERROR ID=$task_id] EN CONVERSION DE OIDs de $desc->{oid} CACHESET");
      return undef;
   }

   #-------------------------------------------------------------------
   my $context='';
   my $remote_port='161';
   my $iid_mode='';
   if ((defined $desc->{'params'}) && ($desc->{'params'} ne '')) {

      #[{"key":"iid_mode","value":"ascii"}]
      my $vparams=[];
      eval { $vparams = decode_json($desc->{'params'}); };
      if ($@) {
         $self->log('warning',"fill_cache:: **ERROR** en decode_json de params >> $desc->{'params'} ($@)");
      }
      foreach my $l (@$vparams) {
         if ($l->{'key'} =~/context/) { $context=$l->{'value'}; }
         elsif ($l->{'key'} =~/remote_port/) { $remote_port=$l->{'value'}; }
         elsif ($l->{'key'} =~/iid_mode/) { $iid_mode=$l->{'value'}; }
      }
      $self->log('info',"fill_cache::[INFO ID=$task_id] CONTEXT=$context REMOTE_PORT=$remote_port IID_MODE=$iid_mode");
   }
   #-------------------------------------------------------------------


   my $res=$self->core_snmp_table($desc);
   my $rcstr=$self->err_str();
   my $rc=$self->err_num();

   if (! defined $res) {
      $self->log('warning',"fill_cache::[WARN ID=$task_id] CACHESET de $desc->{oid} = UNDEF");
      return undef;
   }
   #elsif ($res->[0] eq 'NOSNMP') {
   elsif ($self->response() eq 'NOSNMP') {
      $self->log('info',"fill_cache::[WARN ID=$task_id] CACHESET de $desc->{oid} = NOSNMP");
		#return $res;
		return [$rc, $rcstr, $res];
   }
   else {
#DBG--
      $self->log('debug',"fill_cache::[DEBUG ID=$task_id] CACHESET RESULTADO DEL TABLE = @$res**");
      #ej: 1:@:up:@:up 2:@:up:@:up 3:@:up:@:up
#/DBG--

		my $k=$desc->{'host_ip'}.'.'.$subtype;
		$SNMP_CACHE_RAW{$k}=$res;

      for my $l ( @$res ) {
         my ($id,@v)=split(':@:',$l);
         my $n=scalar @v;
         my $k=$desc->{'host_ip'}.'.'.$subtype.'-'.$id;

			# Hay que tener en cuenta que puede haber iids de la tabla que no esten monitorizados => No existe tarea para esa
			# instancia en 04xxx.idx por eso puede no existir $SNMP_CACHE_TO_OID{$k} que solo contempla los monitorizados.
			# En estos casos es indiferente rellenar la cache o no. La relleno solo por comodidad.
			if ((exists $SNMP_CACHE_TO_OID{$k}) && ($SNMP_CACHE_TO_OID{$k} ne $desc->{'oid'})) {
         	$self->log('debug',"fill_cache::[DEBUG ID=$task_id] --NO CACHESET-- PORQUE KEY=$k DEBE TENER $SNMP_CACHE_TO_OID{$k} Y NO coid= $desc->{'oid'} **");
				next;
				
			}

         if ($iid_mode eq 'ascii') {
            my $k1=$self->key2ascii($k);
            $self->log('debug',"fill_cache::[DEBUG ID=$task_id] ***key2ascii**** KEY1=$k1 FROM KEY=$k");
            $k=$k1;
         }

#DBG--
         $self->log('debug',"fill_cache::[DEBUG ID=$task_id] CACHESET NVAL=$n KEY=$k VAL=@v**");
#/DBG--

         $SNMP_CACHE{$k}=[$rc, $rcstr, \@v];
      }
   }

   if (! defined $SNMP_CACHE{$key} ) {
		my @values=();
		for my $i (0..$num_values-1) { push @values, 'U'; }
      $self->log('debug',"fill_cache::[WARN ID=$task_id] KEY=$key VALUES=@values num_values=$num_values (OID=$desc->{oid})");
      #return \@values;
		return [$rc, $rcstr, \@values];
	}
   else { return $SNMP_CACHE{$key}; }

}


#----------------------------------------------------------------------------
# Funcion: get_metric_params
# Descripcion: Obtiene un hash con los parametros de la metrica, que se almacenan
# con formato JSON en el campo params. (context, remote_port, iid_mode)
#----------------------------------------------------------------------------
sub get_metric_params {
my ($self,$desc) = @_;

   my %params=();
   if ((defined $desc->{'params'}) && ($desc->{'params'} ne '')) {

      #[{"key":"iid_mode","value":"ascii"}]
      my $vparams=[];
      eval { $vparams = decode_json($desc->{'params'}); };
      if ($@) {
         $self->log('warning',"get_metric_params:: **ERROR** en decode_json de params >> $desc->{'params'} ($@)");
      }
      foreach my $l (@$vparams) {
         if ($l->{'key'} =~/context/) { $params{'context'} = $l->{'value'}; }
         elsif ($l->{'key'} =~/remote_port/) { $params{'remote_port'} = $l->{'value'}; }
         elsif ($l->{'key'} =~/iid_mode/) { $params{'iid_mode'} = $l->{'value'}; }
      }
   }
	my $params_found = join(", ", map { "$_=$params{$_}" } keys %params);
   $self->log('info',"get_metric_params:: params_found >> $params_found");
	return \%params;
}


#----------------------------------------------------------------------------
# Funcion: key2ascii
# Descripcion:
#----------------------------------------------------------------------------
sub key2ascii {
my ($self,$key) = @_;

   my ($p1,$p2) = ('','');
   if ($key =~ /(\d+\.\d+\.\d+\.\d+\.custom_\w{8}\-)([\d+|\.+]+)/) {
      $p1=$1;
      $p2=$2;
   }
#192.168.117.114.netscaler_vsvr_health-21.76.66.45.82.68.87.101.98.95.104.116.116.112.114.101.100.105.114.95.53.53
	elsif ($key =~ /(\d+\.\d+\.\d+\.\d+\.[\w+|\_+|]+\-)([\d+|\.+]+)/) {
      $p1=$1;
      $p2=$2;
   }

   my @c = split (/\./,$p2);
   my $txt = '';

   #ojo -> Quito el primero (revisar)
   #FML 20210814 cual es la causa???
   #shift @c;
   foreach my $d (@c) {
      #if ($d<32) { $txt .= '.'; next; }
      if ($d<32) { next; }
      $txt .= chr($d);
   }

   my @words = split(/\./,$txt);
   my $p2n= join('.',  @words);
	$self->log('debug',"key2ascii:: p1=$p1 p2=$p2  (@c) txt=$txt (return=$p1$p2n)");

   return $p1.$p2n;
}



#----------------------------------------------------------------------------
# Funcion: mod_snmp_get
# Descripcion:
#----------------------------------------------------------------------------
sub mod_snmp_get  {
my ($self,$desc)=@_;
my ($data,$t,$values,$items);
my @v=();
my ($rc,$rcstr)=(0,'OK');


   #-------------------------------------------------------------------
   my $task_id=$self->task_id();
	my $mode_flag=$self->mode_flag();

   #-------------------------------------------------------------------
   # Metricas sin IIDs
   #-------------------------------------------------------------------
   if ($desc->{'cfg'} == 1) {
#DBG--
      $self->log('debug',"mod_snmp_get::[DEBUG ID=$task_id] CFG=$desc->{cfg} oid=$desc->{oid}");
#/DBG-
	   $values=$self->core_snmp_get($desc);
   	$rc=$self->err_num();
   	$rcstr=$self->err_str();
	}
	
   #-------------------------------------------------------------------
	# Metricas con IIDs
   #-------------------------------------------------------------------
	elsif ( $desc->{'cfg'} == 2) {

      # clave = ip.subtype (1.1.1.1.traffic_mibii_if-11)
      #-------------------------------------------------------------------
      my $key=$desc->{'host_ip'}.'.'.$desc->{'name'};


		# Proteccion en del caso en el que hay que chequear cosas como traffic_mibii_if-U
		# notificationsd
		if ($desc->{'name'} =~ /.*?-U$/) { 	$values = undef; 	}
	
   	#-------------------------------------------------------------------
   	# Comprobamos si el valor esta en cache.
   	elsif (exists $SNMP_CACHE{$key}) {

			$rc=$SNMP_CACHE{$key}->[0];
			$rcstr=$SNMP_CACHE{$key}->[1];
      	$values= $SNMP_CACHE{$key}->[2];
         $self->err_str($rcstr);
         $self->err_num($rc);

#DBG--
      $self->log('debug',"mod_snmp_get::[DEBUG ID=$task_id] SICACHE CFG=$desc->{cfg} KEY=$key oid=$desc->{oid} VAL=$values");
#/DBG--


   	}

	   #-------------------------------------------------------------------
   	# Si los valores no estan en la cache, se obtienen los valores de toda la tabla y se
   	# almacenan en la cache. Se devuelve el valor pedido de la cache.
   	else {
#DBG--
         $self->log('debug',"mod_snmp_get::[DEBUG ID=$task_id] NOCACHE CFG=$desc->{cfg} KEY=$key oid MOD=$desc->{oid}");
#/DBG--
			my $cache=$self->fill_cache($desc,$key);
			$values=$cache->[2];
		}
	}
	else {
		$self->log('warning',"mod_snmp_get::[WARN ID=$task_id] CFG=$desc->{cfg} (No es 1,2)");
	}

	#-------------------------------------------------------------
	if (!defined $values) {
		#En este caso el problema es del gestor
		$self->log('warning',"mod_snmp_get::[WARN ID=$task_id] VAL=UNDEF oid=$desc->{oid} (MITEMS=$MITEMS)");
		# Se pone U para que se traten correctamente las alertas
		for my $i (0..$MITEMS-1) { push @v, 'U'; }
		$values=\@v;
      my $items = scalar @$values;
      $t=time;
      $data=join(':',$t,@$values);

		#return;
	}
	else {
#DBG--
   	$self->log('debug',"mod_snmp_get::[DEBUG ID=$task_id] ++++++FXM+++++oid=$desc->{oid} VAL=@$values** RC=$rc ($rcstr)");
#/DBG--



		#-------------------------------------------------------------
		# @$values contiene el valor de los oids pero la relacion oid->item
		# viene marcada por fx (campo esp de cfg_monitor_snmp)
		# Esto aplica a cfg=1 o cfg=2
		# Si fx es una funcion TABLE, usa SNMP_CACHE_RAW en lugar de $values
		# porque calcula sobre todo el resultado del walk
		#-------------------------------------------------------------
		$t=time;
		#$values = $self->do_esp_fx($desc,$values);
		my $key=$desc->{'host_ip'}.'.'.$desc->{'subtype'};

		my $store=$self->store();
		my $mode = (exists $desc->{mode}) ? $desc->{mode} : 'gauge' ;
		my $fxm=$self->fxm();
		my $fx=$desc->{'esp'};

      # o1|o2|o3....
      my @fxparts=split(/\|/,$fx);
      my $calculate_fx=0;
      foreach my $x (@fxparts) {
         if ($x !~ /^o\d+$/) { $calculate_fx=1; last; }
      }

		# Si vx != ox e incluye alguna funcion o calculo (ej. o1*10) -> calculate_fx=1
      if ($calculate_fx) {

         # Si es de tipo counter y lleva asociada una funcion de postprocesado se trata como si fuera de modo gauge
         # y las diferencias se calculan por fuera del rrd
         if ($mode=~/counter/i) {

				$values=$store->get_delta_from_file($t,$values,$desc->{file});
				$mode='GAUGE';
				#deltas=1357897426:4:9:13467
$self->log('info',"mod_snmp_get::[DEBUG ID=$task_id] ****store_previous**** t=$t deltas=@$values");


			}

         $fxm->subtype($desc->{'subtype'});
	      if ($fx =~ /^TABLE/) {
  	       	my $key=$desc->{'host_ip'}.'.'.$desc->{'subtype'};
      	   $values=$fxm->parse_fx($fx,$SNMP_CACHE_RAW{$key},$desc);
      	}
			else {
         	$values=$fxm->parse_fx($fx,$values,$desc);
			}
      }

      my $lapse = (exists $desc->{lapse}) ? $desc->{lapse} : 300 ;
      if ($mode=~/gauge/i) {
         if ($lapse !~ /\d+/) { $lapse=300; }
         my $t1 = $t - ($t % $lapse);
         $t=$t1;
      }

		$items = scalar @$values;
		$data=join(':',$t,@$values);

#DBG--
		my $esp=$desc->{'esp'};
      $self->log('debug',"mod_snmp_get::[DEBUG ID=$task_id] oid=$desc->{oid} VAL=@$values** RC=$rc ($rcstr)");
#/DBG--

		if ( ($mode_flag->{rrd}) && ($self->response() ne 'NOSNMP')) {

			# Almacenamiento RRD --------------------------
			#my $rrd=$desc->{file_path}.$desc->{file};
			my $rrd=$self->data_path().$desc->{file};
			#my $store=$self->store();

			if ($store) {	
            #my $mode=$desc->{mode};
            #my $lapse=$desc->{lapse};
            my $type=$desc->{mtype};

				if (! -e $rrd) { 
					$store->create_rrd($rrd,$items,$mode,$lapse,$t-600,$type);  
					my $d600=join(':',$t-600,@$values);
					$store->update_rrd($rrd,$d600);
               my $d300=join(':',$t-300,@$values);
               $store->update_rrd($rrd,$d300);
				}
				my $r = $store->update_rrd($rrd,$data);
				if ($r) {
					my $ru = unlink $rrd;
					$self->log('info',"mod_snmp_get::[DEBUG ID=$task_id] Elimino $rrd  ($ru)");
					$store->create_rrd($rrd,$items,$mode,$lapse,$t-600,$type);
              	my $d600=join(':',$t-600,@$values);
               $store->update_rrd($rrd,$d600);
               my $d300=join(':',$t-300,@$values);
               $store->update_rrd($rrd,$d300);

					$store->update_rrd($rrd,$data);
				}
			}
		}

      if ( $mode_flag->{'db'} ) {
      	my $cid='default';
      	if (exists $desc->{'cid'}) { $cid=$desc->{'cid'}; }
	      if ( ($cid eq "") || ($desc->{mode} eq "") | ($desc->{'subtype'} eq "") ){
   	      $self->log('info',"mod_snmp_get:: VALORES NO VALIDOS $desc->{iddev}.$desc->{subtype} cid=$cid mode=$desc->{mode} subtype=$desc->{subtype}");
      	}
      	else {
         	my $cid_mode_subtype_subtable=$cid.'.'.$desc->{mode}.'-'.$desc->{'subtype'}.'-'.$desc->{'subtable'};
         	push @{$DATA_DIFF{$cid_mode_subtype_subtable}}, {'iddev'=>$desc->{'iddev'}, 'iid'=>$desc->{'iid'}, 'data'=>$data};
			}
      }
	}

   # Control de alertas --------------------------
	if ( ($mode_flag->{'alert'}) && ($desc->{'status'}==0) ) {
		#my $idmetric=$desc->{idmetric};
		my $monitor=$desc->{module}.'&&'.$desc->{oid};
   	$self->mod_alert($monitor,$data,$desc,\@EVENT_DATA);
	}
	
	return ($values,\@EVENT_DATA);
}


#----------------------------------------------------------------------------
# Funcion: mod_snmp_get_ext
# Descripcion:
#----------------------------------------------------------------------------
sub mod_snmp_get_ext  {
my ($self,$desc)=@_;
my ($res,$t);
my $data;
my @v=();
my ($values,$rc,$rcstr);

   #-------------------------------------------------------------------
   my $task_id=$self->task_id();
   my $mode_flag=$self->mode_flag();

#fml
my $rx=$self->response();
$self->log('debug',"mod_snmp_get_ext::[DEBUG ID=$task_id] RESPONSE PREVIO=$rx");

   #-------------------------------------------------------------------
	if (!defined $desc->{ext_function}) {
		$self->log('warning',"mod_snmp_get_ext::[WARN ID=$task_id] ext_function=UNDEF");
		return undef;
	}	

   #-------------------------------------------------------------------
   # Metricas sin IIDs
   #-------------------------------------------------------------------
   if ($desc->{'cfg'} == 1) {
#DBG--
      $self->log('debug',"mod_snmp_get_ext::[DEBUG ID=$task_id] CFG=$desc->{cfg}  oid=$desc->{oid}");
#/DBG-
      $values=$self->core_snmp_get($desc);
      $rc=$self->err_num();
      $rcstr=$self->err_str();
   }
	
   #-------------------------------------------------------------------
   # Metricas con IIDs
   #-------------------------------------------------------------------
   elsif ( $desc->{'cfg'} == 2) {

      # clave = ip.subtype (1.1.1.1.traffic_mibii_if-11)
      #-------------------------------------------------------------------
      my $key=$desc->{'host_ip'}.'.'.$desc->{'name'};

      # Proteccion en del caso en el que hay que chequear cosas como traffic_mibii_if-U
      # notificationsd
      if ($desc->{'name'} =~ /.*?-U$/) {  $values = undef;  }

      #-------------------------------------------------------------------
      # Comprobamos si el valor esta en cache.
      elsif (exists $SNMP_CACHE{$key}) {

         $rc=$SNMP_CACHE{$key}->[0];
         $rcstr=$SNMP_CACHE{$key}->[1];
         $values= $SNMP_CACHE{$key}->[2];
		   $self->err_str($rcstr);
   		$self->err_num($rc);

#DBG--
      $self->log('debug',"mod_snmp_get_ext::[DEBUG ID=$task_id] SICACHE CFG=$desc->{cfg} KEY=$key oid=$desc->{oid} VAL=$values");
#/DBG--

      }

      #-------------------------------------------------------------------
      # Si los valores no estan en la cache, se obtienen los valores de toda la tabla y se
      # almacenan en la cache. Se devuelve el valor pedido de la cache.
      else {
#DBG--
         $self->log('debug',"mod_snmp_get_ext::[DEBUG ID=$task_id] NOCACHE CFG=$desc->{cfg} KEY=$key oid MOD=$desc->{oid}");
#/DBG--
         my $cache=$self->fill_cache($desc,$key);
         $values=$cache->[2];

      }
   }
   else {
      $self->log('warning',"mod_snmp_get_ext::[WARN ID=$task_id] CFG=$desc->{cfg} (No es 1,2)");
   }

   #-------------------------------------------------------------

	if (!defined $values) {
		#En este caso el problema es del gestor
		$self->log('warning',"mod_snmp_get_ext::[WARN ID=$task_id] VAL=UNDEF oid=$desc->{oid}");
		#return;
      # Se pone U para que se traten correctamente las alertas
      for my $i (0..$MITEMS-1) { push @v, 'U'; }
      $values=\@v;
      my $items = scalar @$values;
      $t=time;
      $data=join(':',$t,@$values);

	}

	else {

#DBG--
	   $self->log('debug',"mod_snmp_get_ext::[DEBUG ID=$task_id] oid=$desc->{oid} VAL=@$values***");
#/DBG--

		# ext function ------------------------------------
      $t=time;
      my $items = scalar @$values;
   	$data=join(':',$t,@$values);

		# Si el resultado es U ==> oid no responde, no me molesto en calcular ext_function
#		if ($values->[0] ne 'U') {
  		no strict 'refs';
		$res=&{$desc->{ext_function}}($self,$values,$desc->{ext_params});
  		use strict 'refs';

		$self->log('debug',"mod_snmp_get_ext::[DEBUG]**FML** RES=@$res");

		my $mode = (exists $desc->{mode}) ? $desc->{mode} : 'gauge' ;
		my $lapse = (exists $desc->{lapse}) ? $desc->{lapse} : 300 ;
      if ($mode=~/gauge/i) {
         if ($lapse !~ /\d+/) { $lapse=300; }
         my $t1 = $t - ($t % $lapse);
         $t=$t1;
      }

	
		$items = scalar @$res;
  		$data=join(':',$t,@$res);
#		}

		if ( ($mode_flag->{rrd}) && ($self->response() ne 'NOSNMP')) {

	   	# Almacenamiento RRD --------------------------
   		#my $rrd=$desc->{file_path}.$desc->{file};
   		my $rrd=$self->data_path().$desc->{file};

#$self->log('warning',"snmp_get_ext::**FML** DATA=$data");
	   	my $store=$self->store();

         if ($store) {
            #my $mode=$desc->{mode};
            #my $lapse=$desc->{lapse};
            my $type=$desc->{mtype};

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
					$self->log('info',"mod_snmp_get_ext::[DEBUG ID=$task_id] Elimino $rrd  ($ru)");
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
            $self->log('info',"mod_snmp_get_ext:: VALORES NO VALIDOS $desc->{iddev}.$desc->{subtype} cid=$cid mode=$desc->{mode} subtype=$desc->{subtype}");
         }
         else {
	         my $cid_mode_subtype_subtable=$cid.'.'.$desc->{mode}.'-'.$desc->{'subtype'}.'-'.$desc->{'subtable'};
   	      push @{$DATA_DIFF{$cid_mode_subtype_subtable}}, {'iddev'=>$desc->{'iddev'}, 'iid'=>$desc->{'iid'}, 'data'=>$data};
			}
      }
	}


   # Control de alertas --------------------------
	if ( ($mode_flag->{'alert'}) && ($desc->{'status'}==0) ) {
      #my $idmetric=$desc->{idmetric};
      my $monitor=$desc->{module}.'&&'.$desc->{oid};
		$self->mod_alert($monitor,$data,$desc,\@EVENT_DATA);
   }

   return ($res,\@EVENT_DATA);
}


#----------------------------------------------------------------------------
# Funcion: mod_snmp_walk
# Descripcion:
#----------------------------------------------------------------------------
sub mod_snmp_walk  {
my ($self,$desc)=@_;
my @data=();
my $res;
my ($data,$t);
my $values;


   #-------------------------------------------------------------------
   my $task_id=$self->task_id();
	my $mode_flag=$self->mode_flag();

   #-------------------------------------------------------------------
	# En este caso se almacena todo el vector de datos en la CACHE.
   # La clave = ip.oid (1.1.1.1.oid1_oid2_oid3)
   #-------------------------------------------------------------------
   my $key=$desc->{'host_ip'}.'.'.$desc->{'oid'};

   #-------------------------------------------------------------------
   # Comprobamos si el valor esta en cache.
   if (exists $SNMP_CACHE{$key}) {

      my $rc=$SNMP_CACHE{$key}->[0];
      my $rcstr=$SNMP_CACHE{$key}->[1];
      $values= $SNMP_CACHE{$key}->[2];
      $self->err_str($rcstr);
      $self->err_num($rc);

#DBG--
      $self->log('debug',"mod_snmp_walk::[DEBUG ID=$task_id] SICACHE CFG=$desc->{cfg} oid=$desc->{oid} VAL=$values");
#/DBG--

   }

   #-------------------------------------------------------------------
   # Si los valores no estan en la cache, se obtienen los valores de toda la tabla y se
   # almacenan en la cache. Se devuelve el valor pedido de la cache.
   else {
#DBG--
      $self->log('debug',"mod_snmp_walk::[DEBUG ID=$task_id] CACHESET(table) ip=$desc->{host_ip} mname=$desc->{name} oid=$desc->{oid}**");
#/DBG--
      $res=$self->core_snmp_table($desc);
      if (! defined $res) {
         $self->log('warning',"mod_snmp_walk::[WARN ID=$task_id] TABLE de $desc->{oid} = UNDEF");
         return undef;
      }

		my $rc=$self->err_num();
		my $rcstr=$self->err_str();

$self->log('debug',"mod_snmp_walk::[DEBUG ID=$task_id] CACHESET KEY=$key RC=$rc RCSTR=$rcstr RES=@$res ext_function=$desc->{ext_function}**");



#		my @res_values=();
#     	for my $l ( @$res ) {
#         my ($id,@v)=split(':@:',$l);
#			push @res_values, join (':@:', @v);
#		}
#      $SNMP_CACHE{$key} = [$rc, $rcstr, \@res_values];

      $SNMP_CACHE{$key} = [$rc, $rcstr, $res];
		$values=$SNMP_CACHE{$key}->[2];
	}


   #-------------------------------------------------------------------
	# Control de errores
	my $rc=$self->err_num();
	my $zitems='NA';
	if ($rc != 0) {
		#FML 2026/02/05 Caso particular: esp_cpu_avg_mibhost tiene dos valores de untrada y uno de salida
		if ($desc->{'subtype'} eq 'esp_cpu_avg_mibhost') { $res=['U']; }
		#FML 2026/02/05 Caso particular: esp_arp_mibii_cnt tiene tres valores de untrada y uno de salida
		elsif ($desc->{'subtype'} eq 'esp_arp_mibii_cnt') { $res=['U']; }
		#FML 2026/02/05 Caso particular: esp_arp_mibii_cnt tiene dos valores de untrada y N de salida (N=Num. CPUs)
		elsif ($desc->{'subtype'} eq 'esp_cpu_mibhost') { 
			$zitems=$desc->{'items'};
			my @it = split (/\|/, $desc->{'items'});
			my $j=scalar(@it);	
			my @itu = ();
			foreach (@it) { push @itu, 'U'; }
			$res = \@itu;
		}

		elsif (ref($values) eq "ARRAY") { $res=$values;  }
		else { $res=['U'];  }
      $self->log('warning',"mod_snmp_walk::[WARN ID=$task_id] RC=$rc VAL=@$res oid=$desc->{oid} items=$zitems");
   }
	elsif (! defined $values) {
		$self->log('warning',"mod_snmp_walk::[WARN ID=$task_id] RC=$rc VAL=UNDEF oid=$desc->{oid}");
		$res=[];
	}
	elsif (scalar @$values == 0) {
      $self->log('warning',"mod_snmp_walk::[WARN ID=$task_id] RC=$rc SIN VAL  oid=$desc->{oid}");
		$res=[];
   }
	elsif ($desc->{ext_function} ne '') {
		$self->log('debug',"mod_snmp_walk::[DEBUG ID=$task_id] RC=$rc extf=$desc->{ext_function}**2");

		#----------------------------------------------------------------------
		# Se revisa si hay que ejecutar una funcion de post-procesado de metrica especial.
		$res = $self->core_snmp_esp($desc,$task_id,$values);
	}


if (ref($res) ne 'ARRAY') { $res=[]; }
$self->log('debug',"mod_snmp_walk::[DEBUG ID=$task_id] ****FML0*****");
	my $items = scalar @$res;

$self->log('debug',"mod_snmp_walk::[DEBUG ID=$task_id] ****FML***** ITEMS=$items");
	#----------------------------------------------------------------------	
	# Si items = 0 => No se han obtenido valores del walk => Termino
	if ($items == 0) {
		return (['U'], ['**SIN DATOS DEL DISPOSITIVO**']);
	}

	#----------------------------------------------------------------------	
	
   $t=time;
	my $mode = (exists $desc->{mode}) ? $desc->{mode} : 'gauge' ;
	my $lapse = (exists $desc->{lapse}) ? $desc->{lapse} : 300 ;
   if ($mode=~/gauge/i) {
      if ($lapse !~ /\d+/) { $lapse=300; }
      my $t1 = $t - ($t % $lapse);
      $t=$t1;
   }

   $data=join(':',$t,@$res);


   #-------------------------------------------------------------
   # @$values contiene el valor de los oids pero la relacion oid->item
   # viene marcada por fx (campo esp de cfg_monitor_snmp)
   # Esto solo aplica a cfg=1 o cfg=2
   #-------------------------------------------------------------
   my $fxm=$self->fxm();
   my $fx=$desc->{'esp'};
	if (($fx ne '') && ($desc->{'cfg'} != 3)) {
      $fxm->subtype($desc->{'subtype'});
		$self->log('debug',"mod_snmp_walk::[DEBUG ID=$task_id] HAY FXM ($fxm)  values=@$values**");
      $res=$fxm->parse_fx($fx,$values,$desc);
		$items = scalar @$res;
      $self->log('debug',"mod_snmp_walk::[DEBUG ID=$task_id] HAY FXM ($fxm) VAL=@$res **");
   }


	if ( ($mode_flag->{rrd}) && ($self->response() ne 'NOSNMP')) {

	   # Almacenamiento RRD --------------------------
		#my $rrd=$desc->{file_path}.$desc->{file};
		my $rrd=$self->data_path().$desc->{file};

		my $store=$self->store();

      if ($store) {
         #my $mode=$desc->{mode};
         #my $lapse=$desc->{lapse};
         my $type=$desc->{mtype};

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
            $self->log('info',"mod_snmp_walk::[DEBUG ID=$task_id] Elimino $rrd  ($ru)");
            $store->create_rrd($rrd,$items,$mode,$lapse,$t-600,$type);
            my $d600=join(':',$t-600,@$res);
            $store->update_rrd($rrd,$d600);
            my $d300=join(':',$t-300,@$res);
            $store->update_rrd($rrd,$d300);

            $store->update_rrd($rrd,$data);
         }
      }
	}

$self->log('debug',"mod_snmp_walk::[DEBUG ID=$task_id] ****FML***** AHORA DB");
   if ( $mode_flag->{'db'} ) {
      my $cid='default';
      if (exists $desc->{'cid'}) { $cid=$desc->{'cid'}; }
      if ( ($cid eq "") || ($desc->{mode} eq "") | ($desc->{'subtype'} eq "") ){
         $self->log('info',"mod_snmp_walk:: VALORES NO VALIDOS $desc->{iddev}.$desc->{subtype} cid=$cid mode=$desc->{mode} subtype=$desc->{subtype}");
      }
      else {
	      my $cid_mode_subtype_subtable=$cid.'.'.$desc->{mode}.'-'.$desc->{'subtype'}.'-'.$desc->{'subtable'};
   	   push @{$DATA_DIFF{$cid_mode_subtype_subtable}}, {'iddev'=>$desc->{'iddev'}, 'iid'=>$desc->{'iid'}, 'data'=>$data};
		}
   }
$self->log('debug',"mod_snmp_walk::[DEBUG ID=$task_id] ****FML***** AHORA ALERTS");

   # Control de alertas --------------------------
	if ( ($mode_flag->{'alert'}) && ($desc->{'status'}==0) ) {
      #my $idmetric=$desc->{idmetric};
      my $monitor=$desc->{module}.'&&'.$desc->{oid};
     	$self->mod_alert($monitor,$data,$desc,\@EVENT_DATA);
   }

   return ($res, \@EVENT_DATA);

}

#----------------------------------------------------------------------------
# Funcion: snmp_get_location
# Descripcion:
#----------------------------------------------------------------------------
sub snmp_get_location  {
my ($self,$ip,$community,$version)=@_;
my %params=();

   $params{host_ip}=$ip;
   $params{oid}='.1.3.6.1.2.1.1.6.0';
   $params{community}= (defined $community) ? $community : 'public';
	$params{version}= (defined $version) ? $version : '1';

   my $r=$self->core_snmp_get(\%params);
   my $rc=$self->err_num();
   if ($rc == 0) {
	#if (defined $r) {
		#$r->[0]=~s/^.*?STRING:(.*)$/$1/;
		return $r->[0];
	}
	return undef;
}


#----------------------------------------------------------------------------
# Funcion: snmp_get_description
# Descripcion:
#----------------------------------------------------------------------------
sub snmp_get_description  {
my ($self,$ip,$community,$version)=@_;
my %params=();

   $params{host_ip}=$ip;
   $params{oid}='.1.3.6.1.2.1.1.1.0';
   $params{community}= (defined $community) ? $community : 'public';
	$params{version}= (defined $version) ? $version : '1';

   my $r=$self->core_snmp_get(\%params);
   my $rc=$self->err_num();
   if ($rc == 0) {
   #if (defined $r) {
      #$r->[0]=~s/.*?STRING\:(.*)/$1/;
		return $r->[0];
   }

   return undef;
}

#----------------------------------------------------------------------------
# Funcion: snmp_get_uptime
# Descripcion:
#----------------------------------------------------------------------------
sub snmp_get_uptime  {
my ($self,$ip,$community,$version)=@_;
my %params=();

   $params{host_ip}=$ip;
   $params{oid}='.1.3.6.1.2.1.1.3.0';
   $params{community}= (defined $community) ? $community : 'public';
   $params{version}= (defined $version) ? $version : '1';

   my $r=$self->core_snmp_get(\%params);
   my $rc=$self->err_num();
   if ($rc == 0) { return $r->[0]; }
#   if (defined $r) { return $r->[0]; }
   return 'U';
}


#----------------------------------------------------------------------------
# Funcion: snmp_get_oid
# Descripcion:
#----------------------------------------------------------------------------
sub snmp_get_oid  {
my ($self,$ip,$community,$version)=@_;
my %params=();
	
	$params{host_ip}=$ip;
	$params{oid}='.1.3.6.1.2.1.1.2.0';	
   $params{community}= (defined $community) ? $community : 'public';
	$params{version}= (defined $version) ? $version : '1';

   my $r=$self->core_snmp_get(\%params);
   my $rc=$self->err_num();
   if ($rc == 0) {
   #if (defined $r) {
      #$r->[0]=~s/.*?OID\:(.*)/$1/;
		return $r->[0];
   }

   return undef;
}


#----------------------------------------------------------------------------
# Funcion: snmp_get_name
# Descripcion:
#----------------------------------------------------------------------------
sub snmp_get_name  {
my ($self,$ip,$community,$version)=@_;
my %params=();

   $params{host_ip}=$ip;
   $params{oid}='.1.3.6.1.2.1.1.5.0';
   $params{community}= (defined $community) ? $community : 'public';
   $params{version}= (defined $version) ? $version : '1';

   my $r=$self->core_snmp_get(\%params);
   my $rc=$self->err_num();
   if ($rc == 0) {
   #if (defined $r) {
      #$r->[0]=~s/.*?OID\:(.*)/$1/;
      return $r->[0];
   }

   return undef;
}


#----------------------------------------------------------------------------
# Funcion: snmp_get_netmask
# Descripcion:
#----------------------------------------------------------------------------
sub snmp_get_netmask  {
#my ($self,$ip,$community,$version)=@_;
my ($self,$desc,$ip)=@_;

#my %params=();

#.1.3.6.1.2.1.4.20.1.3.10.2.254.223
#IP-MIB::ipAdEntNetMask.10.2.254.223

#   $params{host_ip}=$ip;
#   $params{oid}='.1.3.6.1.2.1.4.20.1.3.'.$ip;
#   $params{community}= (defined $community) ? $community : 'public';
#   $params{version}= (defined $version) ? $version : '1';

	$desc->{oid}='.1.3.6.1.2.1.4.20.1.3.'.$ip;
   my $r=$self->core_snmp_get($desc);
   my $rc=$self->err_num();
   if ($rc == 0) {
      return $r->[0];
   }

   return undef;
}

#----------------------------------------------------------------------------
# Funcion: snmp_get_bridge_ports
# Descripcion:
#----------------------------------------------------------------------------
sub snmp_get_bridge_ports  {
my ($self,$desc,$ip)=@_;

# BRIDGE-MIB::dot1dBaseNumPorts.0 = INTEGER: 12
# .1.3.6.1.2.1.17.1.2.0

   $desc->{oid}='.1.3.6.1.2.1.17.1.2.0';
   my $r=$self->core_snmp_get($desc);
   my $rc=$self->err_num();
   if ($rc == 0) {
      return $r->[0];
   }

   return undef;
}

#----------------------------------------------------------------------------
# Funcion: snmp_get_mac
# Descripcion: Obtiene la MAC asociada a una determinada IP por SNMP MIB2
#----------------------------------------------------------------------------
sub snmp_get_mac  {
my ($self,$desc,$ip)=@_;

   my %IF2MAC=();
   my %IF2IP=();
   my ($mac,$mac_vendor) = ('-','');
   $desc->{'oid'}='RFC1213-MIB::ifTable';
   my $iftable=$self->core_snmp_table_hash($desc);
   foreach my $iid (keys %$iftable) {
      if (exists $iftable->{$iid}->{'ifPhysAddress'}) {
         my $mac_raw = $iftable->{$iid}->{'ifPhysAddress'};
         $mac_raw =~ s/^"*(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s*"*$/$1\:$2\:$3\:$4\:$5\:$6/;

			my @bytes = split (/\:/,$mac_raw);
			if (scalar(@bytes)<6) { next;}
			for my $i (0..scalar(@bytes)-1) {
   			my $bx=$bytes[$i];
   			my $cnt = map $_, $bx =~ /(.)/gs;
   			if ($cnt == 1) {$bytes[$i] = '0'.$bx; }
			}
			$mac_raw = join (':', @bytes);

         $IF2MAC{$iid}= lc $mac_raw;
      }
   }

   $desc->{oid}='IP-MIB::ipAddrTable';
   my $iptable=$self->core_snmp_table_hash($desc);
   foreach my $ip (keys %$iptable) {
      my $iid = $iptable->{$ip}->{'ipAdEntIfIndex'};
      $IF2IP{$ip}=$iid;
   }

   if (exists $IF2IP{$ip}) {
      my $iid = $IF2IP{$ip};
      if (exists $IF2MAC{$iid}) { $mac = $IF2MAC{$iid}; }
   }
   else {
      my %unique_macs=();
		my $first_mac='';
      foreach my $iid (sort {$a <=> $b} keys %IF2MAC) { 
			my $m=$IF2MAC{$iid};
#print "MAC=$m\n";
			if ($m=~/^(\w{2}\:\w{2}\:\w{2})/) { 
				$unique_macs{$1}=1; 
				if ($first_mac eq '') { $first_mac=$m; }
			} 
		}
      if (scalar(keys %unique_macs)==1) { $mac = $first_mac; } 
   }

	if ($mac eq '-') { return ($mac,$mac_vendor); }

	# --------------------------------------
	# MAC Vendor
	# --------------------------------------
   eval {
      require IEEEData;
      IEEEData->import();
   };

   if ($@) {
		$self->log('error',"snmp_get_mac:: ERROR en import ($@)");
	}
	else {

      if ($mac =~ /^(\w{2}\:\w{2}\:\w{2})\:\S+$/) {
         my $k = uc $1;
         $mac_vendor = (exists $IEEEData::MAC_TABLE{$k}) ? $IEEEData::MAC_TABLE{$k} : '';
      }
   }

	return ($mac,$mac_vendor);
}


#----------------------------------------------------------------------------
# Funcion: snmp_get_serialn
# Descripcion: Obtiene el numero de serie de una determinada IP por SNMP
# En funcion de sysObjectOID implementa una u otra consulta 
#----------------------------------------------------------------------------
sub snmp_get_serialn  {
my ($self,$desc,$ip)=@_;


	my ($serialn,$sysoid,$f2key) = ('','','');
	if (exists $desc->{'sysoid'}) { 
		$sysoid = $desc->{'sysoid'}; 
		if ( $desc->{'sysoid'} =~ /9/ ) { $f2key='cisco'; }
	}
	else {
		$self->log('warning',"snmp_get_serialn:: NO EXISTE sysoid");
   	return $serialn;
	}

	if ($f2key eq '') { return $serialn; }

	$self->log('info',"snmp_get_serialn:: f2key=$f2key ($desc->{'sysoid'})");

	if (exists $ProvisionLite::Serialfx{$f2key}) {
		$serialn = &{$ProvisionLite::Serialfx{$f2key}}($desc,$self);
	}
	else {
		$self->log('warning',"snmp_get_serialn:: NO DEFINIDA fx PARA f2key=$f2key");
	}

   return $serialn;
}


#----------------------------------------------------------------------------
# Funcion: snmp_check_table
# Descripcion:
#----------------------------------------------------------------------------
sub snmp_check_table  {
my ($self,$desc,$oid_list)=@_;


#$desc->{host_ip};
#$desc->{oid};
#$desc->{community};
#$desc->{version};
#$desc->{'auth_proto'};
#$desc->{'auth_pass'};
#$desc->{'priv_proto'};
#$desc->{'priv_pass'};
#$desc->{'sec_name'};
#$desc->{'sec_level'};


	my @result=();
	my $r;
	for my $oid (keys %$oid_list) {

		if ($oid !~ /\.\d+$/) {
			#No uso gettable porque petardea con tablas grandes (ipsec, cisco process ...)
   		#$r=$self->core_snmp_table_hash($desc);
			$r=$self->core_snmp_table($desc);
			my $rc=$self->err_num();
	      #if ( ($rc==0) && (scalar(keys %$r)>0)) { $oid_list->{$oid}=1; }
	      if ( ($rc==0) && (scalar($r)>0)) { $oid_list->{$oid}=1; }
   	   else { $oid_list->{$oid}=0; }
      	push @result,$r;
		}
		else {
			$desc->{oid}=$oid;
			$r=$self->core_snmp_get($desc);
			my $rc=$self->err_num();
			if ( ($rc==0) && (scalar(@$r)>0)) { $oid_list->{$oid}=1; }
			else { $oid_list->{$oid}=0; }
		}
	}

	#Solo aparecen en los resultados las tablas
	return \@result;
}



#----------------------------------------------------------------------------
# snmp_check_table_cols
#----------------------------------------------------------------------------
# A partir de una tabla snmp devuelve una estructura con las columnas soportadas
#
#          'TCP-MIB::tcpConnTable' => {
#                                       'tcpConnLocalAddress' => 1,
#                                       'tcpConnRemPort' => 1,
#                                       'tcpConnLocalPort' => 1,
#                                       'tcpConnState' => 1,
#                                       'tcpConnRemAddress' => 1
#                                     },
#
#----------------------------------------------------------------------------
sub snmp_check_table_cols  {
my ($self,$desc,$oid_list,$timeout_max)=@_;

   my %result=();
   my $r;
   for my $oid (keys %$oid_list) {

		$self->log('debug',"snmp_check_table_cols::[INFO] PROCESANDO OID=$oid");		
      $desc->{oid}=$oid;
      if ($oid !~ /\.\d+$/) {
         #$r=$self->core_snmp_table_hash($desc,$timeout_max);
			$r=$self->core_snmp_get_columns($desc);
# $r es del tipo:
#$r = {
#          '6' => {
#                   'hrStorageSize' => '149268',
#                   'hrStorageAllocationUnits' => '1024',
#                   'hrStorageDescr' => 'Memory buffers',
#                   'hrStorageIndex' => '6',
#                   'hrStorageType' => '.1.3.6.1.2.1.25.2.1.1'
#                 },
#          '33' => {
#                    'hrStorageSize' => '0',
#                    'hrStorageAllocationUnits' => '4096',
#                    'hrStorageUsed' => '0',
#                    'hrStorageDescr' => '/sys/kernel/debug',
#                    'hrStorageIndex' => '33',
#                    'hrStorageType' => '.1.3.6.1.2.1.25.2.1.4'
#                  },
#          '32' => {
# 				.................
#
         my $rc=$self->err_num();
         if ($rc!=0) {
            my $err_str=$self->err_str();
				$self->log('info',"snmp_check_table_cols::[INFO] OID=$oid ERROR=$err_str (rc=$rc)");
				$oid_list->{$oid}=0;
			}
         elsif (scalar(keys %$r)>0) {
				#my @ke=keys(%$r);
         	#my $x=$ke[0];
         	#if ( (ref($r->{$x}) eq "HASH") && ($x ne "") ) {
				#	$oid_list->{$oid}=1;
            #	my @gg=keys(%{$r->{$x}});
            #	foreach my $g (@gg) { $result{$oid}{$g}=1; }
            #	#push @result,$r;
         	#}

				foreach my $x (keys %$r) {
	            if ( (ref($r->{$x}) eq "HASH") && ($x ne "") ) {
   	            $oid_list->{$oid}=1;
      	         my @gg=keys(%{$r->{$x}});
         	      foreach my $g (@gg) { $result{$oid}{$g}=1; }
            	   #push @result,$r;
            	}
				}
			}
         else { $oid_list->{$oid}=0;  }

print "-----------------------DEBUG snmp_check_table_cols ($oid) --------------\n";
print Dumper($r);

      }
      else {
print "-----------------------DEBUG snmp_check_snmp_get ($oid) --------------\n";
print Dumper($desc);

         $r=$self->core_snmp_get($desc);
         my $rc=$self->err_num();
         if ( ($rc==0) && (scalar(@$r)>0)) { $oid_list->{$oid}=1; }
         else { $oid_list->{$oid}=0; }
      }
   }
   #Solo aparecen en los resultados las tablas
   return \%result;
}

#----------------------------------------------------------------------------
# Funcion: snmp_get_enterprise
# Descripcion:
#----------------------------------------------------------------------------
sub snmp_get_enterprise  {
my ($self,$oid_name)=@_;

	my $enterprise=0;

   # FML!! PARCHE MSFT-MIB::workstation y server
	if ($oid_name eq 'workstation') {
		$oid_name='MSFT-MIB::workstation';
		$enterprise=311;
	}
	elsif ($oid_name eq 'server') {
		$oid_name='MSFT-MIB::server';
		$enterprise=311;
	}
	# Caso general
	else {
		my $oid=SNMP::translateObj($oid_name);
		if ($oid=~/1\.3\.6\.1\.4\.1\.(\d+)/) { $enterprise=$1; }
	}

	return $enterprise;

}

#----------------------------------------------------------------------------
# Funcion: snmp_get_version_old
# Descripcion:
# OUT: 2 => version 2 , 1 => version 1 , 0 => no responde a SNMP
#----------------------------------------------------------------------------
sub snmp_get_version_old  {
my ($self,$ip,$community)=@_;
my $rc;

#	$rc=$self->snmp_get_oid($ip,$community,2);
#	if ( (defined $rc) && ($rc ne 'U') ) { return 2; }
#
#   $rc=$self->snmp_get_oid($ip,$community,1);
#   if ( (defined $rc) && ($rc ne 'U') ) { return 1; }
#
#   $rc=$self->snmp_get_uptime($ip,$community,2);
#   if ( (defined $rc) && ($rc ne 'U') ) { return 2; }
#
#   $rc=$self->snmp_get_uptime($ip,$community,1);
#   if ( (defined $rc) && ($rc ne 'U') ) { return 1; }

   $rc=$self->snmp_get_name($ip,$community,2);
   if ( (defined $rc) && ($rc ne 'U') ) { return 2; }

   $rc=$self->snmp_get_name($ip,$community,1);
   if ( (defined $rc) && ($rc ne 'U') ) { return 1; }


	return 0;

}


#----------------------------------------------------------------------------
# Funcion: snmp_get_table
# Descripcion:
#  Obtiene los datos de una tabla. Los datos se pasan como parametro.
#	1. Permite obtener de forma comoda los datos de la tabla.
#	2. Permite obtener las instancias y tambien el numero de instancias
#		haciendo scalar @$res
# IN: Oids del tipo: sysDescr_sysObjectID_sysName_sysLocation
# OUT: ($rc, $rcstr,$res)
#
#  $rc: Codigo de retorno 0->OK, !=0->NOK
#  $rcstr: Mensaje de error
#  $res: Resultado (core_snmp_table). Es un array del tipo:
#
#     v1:@:v2:@:v3....vn
#     v1:@:v2:@:v3....vn
#     v1:@:v2:@:v3....vn
#
#----------------------------------------------------------------------------
sub snmp_get_table  {
my ($self,$desc,$oid)=@_;

   my $rc=0;
   my $rcstr='';

   my %D=();
   $D{'host_ip'} = $desc->{'host_ip'};
   $D{'community'} = $desc->{'community'};
   $D{'version'} = $desc->{'version'};
   $D{'oid'} = $oid;

   #----------------------------------------------------------------------------
   my $res=$self->core_snmp_table(\%D);
   $rc=$self->err_num();
   $rcstr=$self->err_str();
   return ($rc, $rcstr,$res);

}


#----------------------------------------------------------------------------
# Funcion: snmp_get_version
# Descripcion:
# OUT: 2 => version 2 , 1 => version 1 , 0 => no responde a SNMP
# 	Como para calcular la version chequea la parte system de la MIB2, en el
#	parametro rdata incluye el valor de las instancias chequeadas.
#
#	**********OBSOLETA !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#----------------------------------------------------------------------------
sub snmp_get_version  {
my ($self,$ip,$community,$rdata)=@_;

	my ($v1warn,$v2warn) = (0,0);
   #---------------------------------------------------------------
   # Busco version SNMP
   my %SNMPCFG = ();
   $SNMPCFG{'host_ip'} = $ip;
   $SNMPCFG{'community'} = $community;
   $SNMPCFG{'version'} = 2;

	# Se inicializa en caso de no haber respuesta
   $rdata->{'sysdesc'} = '** sin respuesta snmp **';
   $rdata->{'sysoid'} = '** sin respuesta snmp **';
   $rdata->{'sysname'} = '** sin respuesta snmp **';
   $rdata->{'sysloc'} = '** sin respuesta snmp **';
	#legacy, en algunos casos se utilizan oid y sysoid indistintamente.
	$rdata->{'oid'}=$rdata->{'sysoid'};

   #sysDescr_sysObjectID_sysName_sysLocation
   my ($rc, $rcstr, $res)=$self->verify_snmp_data(\%SNMPCFG);
   if ($rc != 0) {
      # Es el caso de noSuchName
      if ($rc == 2) {$v2warn=1;  }
      #else { return 0; }
   }
	else {
		my $ok=0;
	   foreach my $l (@$res) {
   	   my @rd=split(':@:', $l);
			$rdata->{'sysdesc'} = $rd[1];
			$rdata->{'sysoid'} = $rd[2];
			$rdata->{'sysname'} =$rd[3] ;
			$rdata->{'sysloc'} = $rd[4];
			#legacy, en algunos casos se utilizan oid y sysoid indistintamente.
			$rdata->{'oid'}=$rdata->{'sysoid'};
			$ok=1;
   	}
		if ($ok) { return 2; }
		return 0;
	}

   $SNMPCFG{'version'} = 1;
	($rc, $rcstr, $res)=$self->verify_snmp_data(\%SNMPCFG);
   if ($rc != 0) {
      # Es el caso de noSuchName
      if ($rc == 2) {
         if ($v2warn) { return 2; }
         else { return 1;  }
      }
      else { return 0; }
   }
   else {
      my $ok=0;
      foreach my $l (@$res) {
         my @rd=split(':@:', $l);
         $rdata->{'sysdesc'} = $rd[1];
         $rdata->{'sysoid'} = $rd[2];
         $rdata->{'sysname'} =$rd[3] ;
         $rdata->{'sysloc'} = $rd[4];
			#legacy, en algunos casos se utilizan oid y sysoid indistintamente.
			$rdata->{'oid'}=$rdata->{'sysoid'};
         $ok=1;
      }
      if ($ok) { return 1; }
	}
}

#----------------------------------------------------------------------------
# Funcion: snmp_prepare_info
# Descripcion:
# Adapta los datos de informacion (sysoid, sysname, sysloc ...) obtenidos
# por snmp_get_version
# IN => Hash de datos
# OUT => Hash de datos
#----------------------------------------------------------------------------
sub snmp_prepare_info {
my ($self,$rdata)=@_;

   #---------------------------------------------------------------
   $rdata->{'sysdesc'} =~ s/\n/  /g;
   $rdata->{'sysoid'} =~ s/\n/  /g;
   $rdata->{'sysname'} =~ s/\n/  /g;
   $rdata->{'sysloc'} =~ s/\n/  /g;

	if ($rdata->{'sysoid'} =~ /sin respuesta snmp/ ) { return; }

   # sysoid se debe almacenar en modo numerico porque asi esta contemplado en la tabla prov_default_metrics para
   # asociar metricas a tipos de dispositivos. Esto se consigue mediante &SNMP::translateObj
   # pero como no utilizamos la opcion de long_names al utilizar nombres en lugar de valores numericos, hay
   # casos en los que hay conflico en la traduccion por lo tanto existen algunas EXCEPCIONES !!!!
   if ($rdata->{'sysoid'} eq 'server') { $rdata->{'sysoid'}='MSFT-MIB::'.$rdata->{'sysoid'}; }
   elsif ($rdata->{'sysoid'} eq 'workstation') { $rdata->{'sysoid'}='MSFT-MIB::'.$rdata->{'sysoid'}; }
	$rdata->{'sysoid'} = &SNMP::translateObj($rdata->{'sysoid'});

}


#----------------------------------------------------------------------------
# Funcion: snmp_get_cmd
# Descripcion:
#----------------------------------------------------------------------------
sub snmp_get_cmd  {
my ($self,$desc)=@_;
my $error;
my @values=();

my $host=$desc->{host_ip};
my $oid=$desc->{oid};

   my @o=split(/\|/,$oid);
   foreach (@o) {
      my $cmd="/usr/local/bin/snmpget -v 1 -c public $host $_";
      my $r=`$cmd`;

      if (! defined $r) {
			$self->log('warning',"snmp_get_cmd::[WARN] CMD=$cmd -> RES=UNDEF");
			push @values,0;
			next;
		}

		push @values,$r;
#DBG--
		$self->log('debug',"snmp_get_cmd::[DEBUG] $_ -> $r");
#/DBG--
   }

	return \@values;

}


#----------------------------------------------------------------------------
# Funcion: snmp_walk
# Descripcion:
#----------------------------------------------------------------------------
sub snmp_walk  {
my ($self,$desc)=@_;

   my ($rc,$rcstr) = (0,'');
   $self->err_str($rcstr);
   $self->err_num($rc);

   my $host=$desc->{'host_ip'};
   my $oid=$desc->{'oid'};
   my $version=$desc->{'version'} || '1';
   if ($version=~/2/) { $version='2c'; }
   my $community=$desc->{'community'} || 'public';

   #------------------------
   my @cols=();
   my $dir_cache = '/opt/data/cache/mib_tables';
   if (! -d  $dir_cache) { make_path($dir_cache); }
   my $fcache = $dir_cache .'/'. $oid;
   if ((-f $fcache) && ((-s $fcache)>0)) {
      open (F,"<$fcache");
      while (<F>) {
         chomp;
         push @cols, $_;
      }
      close F;
   }
   else {

      my @lines = `/usr/local/bin/snmptranslate -Tp -OS $oid`;
      open (F,">$fcache");
      foreach my $l (@lines) {
         chomp $l;
         if ($l =~ /\+\-\-\s+\S{4}\s+\S+\s+(\S+)\(\d+\)$/) {
            push @cols,$1;
            print F "$1\n";
         }
      }
      close F;
   }

   if (scalar(@cols)==0) {
      $rc=1;
      $rcstr="NO EXISTE OID $oid";
      $self->err_str($rcstr);
      $self->err_num($rc);

      $self->log('info',"snmp_walk::[INFO **NO EXISTE OID** oid=$oid**");
      return [];
   }

   my @varlist=map([$_], @cols);
   # Hay que validar los resultados porque aunque el agente remoto responda a getnext
   # puede responder la primera vez con un oid diferente.
   # %validate se usa para confirmar que responde a lo que se le pregunta
   my %validate=();
   my $first_col='';
   foreach my $x (@varlist) {
      $validate{$x->[0]}=0;
      if ($first_col eq '') { $first_col=$x->[0]; }
   }
   #----------------------------

   my $cmd="/usr/local/bin/snmpwalk -Cc -v $version -c $community $host $oid";
   my @r=`$cmd`;
   my $num_rows = scalar(@r);
   $self->log('debug',"snmp_walk::[DEBUG] ROWS=$num_rows [$cmd]");

   #Raw mode
   my %walk=();
   foreach my $l (@r) {
      chomp $l;
#print "$l\n";
      #CPQIDA-MIB::cpqDaPhyDrvFailureCode.31.1 = INTEGER: 0
      if ($l =~ /^(\S+)\s*\=\s*(\w+\:)\s*(.+)$/) {
         my ($full_oid,$type,$value,$mib,$oid,$iid)=($1,$2,$3,'','','');
         if ($full_oid =~ /(\S+)\:\:(\w+)\.(.+)/) { ($mib,$oid,$iid)=($1,$2,$3); }
         $walk{$oid}->{$iid}=$value;
         $validate{$oid}=1;
      }
   }

   # Hash by IID
   my %walk_by_iid = ();
   my @oids = sort keys %walk;
   my @iids = sort keys %{$walk{$first_col}};
   my @line = ();
   foreach my $iid (@iids) {
      $walk_by_iid{$iid}={};
      foreach my $oid (@oids) {
         $walk_by_iid{$iid}->{$oid} = $walk{$oid}->{$iid};
      }
   }

#DEBUG FML
$self->log('info',"snmp_walk::[DEBUG] ROWS=$num_rows [$cmd] >> --$first_col--");


   # Table print
   #my @oids = sort keys %walk;
   #my @iids = sort keys %{$walk{$oids[0]}};
   #my @all_lines = ();
   #foreach my $iid (@iids) {
   #   my @line = ($iid);
   #   foreach my $oid (@oids) {
   #      push @line, $walk{$oid}->{$iid};
   #   }
   #   push @all_lines, \@line;
   #}
   # return \@all_lines;

   return \%walk_by_iid;

#	my $host=$desc->{host_ip};
#	my $oid=$desc->{oid};
#	
#   my $cmd="/usr/local/bin/snmpwalk -Cc -v 1 -c public $host $oid";
#   my $r=`$cmd`;

#   $self->log('debug',"snmp_walk::[DEBUG] CMD=$cmd");
#   if (defined $r) { $self->log('debug',"snmp_walk::[DEBUG] RES=$r");}
#   else { $self->log('warning',"snmp_walk::[WARN] RES=UNDEF");}

}



#----------------------------------------------------------------------------
# Funcion: snmp_get_iid
# Descripcion:
#----------------------------------------------------------------------------
sub snmp_get_iid  {
my ($self,$desc)=@_;

#          'version' => '2',
#          'oid' => 'hrStorageDescr',
#          'last' => undef,
#          'start_col' => 0,
#          'community' => 'public',
#          'format' => 'txt',
#          'host_ip' => '10.95.12.56'


	# oid_tab son los oids que se monitorizan de la tabla 
	# p.ej hrStorageAllocationUnits.IID|hrStorageSize.IID
	# Si son varios, nos quedamos con el primero porque es suficiente para obtener los OIDS que tiene la tabla
   my $oid_tab=$desc->{'oid_tab'};
   $oid_tab =~ s/^(\S+)\.IID.*$/$1/;

	# oid Incluye el oid/oids con la descripcion de cada elemento de la tabla.
   my @oids=split(/\|/,$desc->{'oid'});
   #my @oids=split(/\|/,$oid_descr_param);
   my @IIDS=();
   my %SEARCHED_IIDS=();

   my $version=$desc->{'version'};
   my $community=$desc->{'community'};
   my $ip=$desc->{'host_ip'};

   my $cmd_base='';
   if ($version==3) {
      $cmd_base="/usr/local/bin/snmpwalk -Cc -r 10 -v $version ";

      $cmd_base .=  ($desc->{'sec_level'}) ? "-l $desc->{'sec_level'} " : "";
      $cmd_base .=  ($desc->{'sec_name'}) ? "-u $desc->{'sec_name'} " : "";
      $cmd_base .=  ($desc->{'auth_proto'}) ? "-a $desc->{'auth_proto'} " : "";
      $cmd_base .=  ($desc->{'auth_pass'}) ? "-A $desc->{'auth_pass'} " : "";
      $cmd_base .=  ($desc->{'priv_proto'}) ? "-x $desc->{'priv_proto'} " : "";
      $cmd_base .=  ($desc->{'priv_pass'}) ? "-X $desc->{'priv_pass'} " : "";
   }
   else {
      if ($version eq '2') { $version='2c'; }
      $cmd_base="/usr/local/bin/snmpwalk -Cc -v $version -c $community";
   }


   #$cmd_base .= " $ip __OID__ 2>/dev/null";
	$cmd_base .= " $ip __OID__ ";
	
   if ( $oid_tab ) {
      my $cmd1=$cmd_base;
      $cmd1 =~ s/__OID__/$oid_tab/;
      $self->log('debug',"snmp_get_iid::[DEBUG] oid_tab=$oid_tab");
      $self->log('debug',"snmp_get_iid::[DEBUG] safe_snmpwalk >> CMD=$cmd1");
      #my @r1=`$cmd1`;
		my $r1=$self->safe_snmpwalk($cmd1);
      foreach my $o (@$r1) {
			chomp $o;
         #IF-MIB::ifDescr.1 = STRING: lo
         $self->log('debug',"snmp_get_iid::[DEBUG] EVALUO EN OID_TAB $o ($oid_tab)");
         if ($o=~/$oid_tab\.(\S+)\s*\=\s*.*?\:\s*(.*)$/) {
            my $oidx=$1;
            $oidx=~s/"//g;
            $oidx=~s/'//g;
            $self->log('debug',"snmp_get_iid::[DEBUG] SEARCHED_IID = $oidx");
            $SEARCHED_IIDS{$oidx}='';
         }
      }
   }

   foreach my $oid_descr (@oids) {

      my $oid_descr_short=$oid_descr;
      if ($oid_descr=~/^.*\:\:(.*)$/) { $oid_descr_short=$1; }

      $self->log('debug',"snmp_get_iid::[DEBUG] OID-DESCR=$oid_descr SHORT=$oid_descr_short");

      my $cmd1=$cmd_base;
      $cmd1 =~ s/__OID__/$oid_descr/;
      $self->log('debug',"snmp_get_iid::[DEBUG] safe_snmpwalk >> CMD=$cmd1");

      #my @r1=`$cmd1`;
		my $r1=$self->safe_snmpwalk($cmd1);

      my %d=();
		my ($oidx,$vartype,$descrx,$descr_raw)=('','','','');
      foreach my $o (@$r1) {
			chomp $o;
         $self->log('debug',"snmp_get_iid::[DEBUG] EVALUO $o ($oid_descr_short)");
			if ($o =~ /\S+\:\:$oid_descr_short\.(\S+)\s*\=\s*(.*?)\:\s*(.*)$/) {
				$oidx=$1; $vartype=$2; $descrx=$3; $descr_raw=$descrx;
				$oidx=~s/"//g;
				$oidx=~s/'//g;
				if ($vartype =~/Hex-STRING/i) { $descrx=$self->hex2ascii($descr_raw); }
				$d{$oidx}=$descrx;
				$self->log('debug',"snmp_get_iid::[DEBUG] OK >> oidx=$oidx descrx=$descrx");
         	if ( ! $oid_tab ) { $SEARCHED_IIDS{$oidx}=''; }
			}
      }
      push @IIDS, \%d;
   }

   foreach my $iid (keys %SEARCHED_IIDS) {

		# CASO A. (a=b, 1=1, 1.1=1.1)
			my $ok=0;
         my $h=$IIDS[0];
         foreach my $k (keys %$h) {
            if ($k eq $iid) {
               my @aux=();
               for my $i (0..scalar(@IIDS)-1) { push @aux, $IIDS[$i]->{$k}; }
               $SEARCHED_IIDS{$iid} = join('.',@aux);

               #$SEARCHED_IIDS{$iid} = $h->{$k};
					$ok=1;
               last;
            }
         }
			if ($ok) {next; }



		# CASO B. Multidimensional 
      my @parts=split(/\./,$iid);
      my $c=0;
      foreach my $i (@parts) {
         my $h=$IIDS[$c];
         foreach my $k (keys %$h) {
            if ($k eq $i) {
               $SEARCHED_IIDS{$iid} .= $h->{$k};
               last;
            }
         }
         $c+=1;
      }
   }
#     print Dumper(\%SEARCHED_IIDS);

#   foreach my $k (sort {$a<=>$b} keys %SEARCHED_IIDS) {
#         print "$k : $SEARCHED_IIDS{$k}\n";
#   }

   return \%SEARCHED_IIDS;

}


#----------------------------------------------------------------------------
# Funcion: core_snmp_set
# Descripcion:
#----------------------------------------------------------------------------
sub core_snmp_set  {
my ($self,$desc)=@_;

my ($r,$rc,$rcstr);
my $host=$desc->{host_ip};
my $oid=$desc->{oid};
my $community=$desc->{community};
#Tipos:OBJECTID,OCTETSTR,INTEGER,NETADDR,IPADDR,COUNTER,COUNTER64,GAUGE,UINTEGER,TICKS,OPAQUE
my $oid_type=$desc->{oid_type};
my $value=$desc->{value};

   $SNMP::auto_init_mib=0;
	my $timeout=$self->timeout();
	my $retries=$self->retries();
   my $session = new SNMP::Session(DestHost => $host,
                                 Community => $community,
                                 Timeout =>$timeout,
                                 Retries => $retries);

   if (!defined($session)) {
      $rc=1;
		$rcstr='ERROR en sesion '.$SNMP::Session::ErrorStr;
      $self->err_str($rcstr);
      $self->err_num($rc);
      $self->log('warning',"core_snmp_set::[WARN] Error en conexion a $host/$community ($rc:$rcstr) (Timeout=$timeout|Retries=$retries)");
      undef $session;
      return undef;
   }

   #$response= $session->set([["$SNMP_CONFIG_OID",$SNMP_CONFIG_IID, $msg , "OCTETSTR"]]);
   my $response= $session->set([["$oid",'', $value , $oid_type]]);

   if (!defined($response)) {
      $rc=$session->{ErrorNum};
      $rcstr=$session->{ErrorStr};
      $self->err_str($rcstr);
      $self->err_num($rc);
		$self->log('warning',"core_snmp_set::[WARN] SET  HOST=$host ($value [$oid_type] ->$oid) ($rc:$rcstr)");
		undef $session;
      return undef;
   }

	undef $session;
	return;
}

#----------------------------------------------------------------------------
# Funcion: core_snmp_get_columns
# Descripcion:
# IN:
# OUT:
# Devuelve una referencia a un vector con los datos pedidos. Si no hay respuesta
# los valores son 'U'. Pero siempre existen los valores.
# En $self->err_num y $self->err_str estan los codigos de error
#----------------------------------------------------------------------------
sub core_snmp_get_columns  {
my ($self,$desc)=@_;
my ($r,$rc,$rcstr);
my $host=$desc->{host_ip};
my $oid=$desc->{oid};
my $community=$desc->{community};
my $version= (defined $desc->{version}) ? $desc->{version} : 1;
my $auth_proto = (defined $desc->{'auth_proto'}) ? $desc->{'auth_proto'} : 'MD5' ;
my $auth_pass = (defined $desc->{'auth_pass'}) ? $desc->{'auth_pass'} : '' ;
my $priv_proto = (defined $desc->{'priv_proto'}) ? $desc->{'priv_proto'} : 'DES' ;
my $priv_pass = (defined $desc->{'priv_pass'}) ? $desc->{'priv_pass'} : '' ;
my $sec_name = (defined $desc->{'sec_name'}) ? $desc->{'sec_name'} : '' ;
my $sec_level = (defined $desc->{'sec_level'}) ? $desc->{'sec_level'} : '' ;


   #-------------------------------------------------------------------
   my $task_id=$self->task_id();
   $self->response('OK');

   #-------------------------------------------------------------------
   if (( exists $SNMP_CACHE{$host}) && ($SNMP_CACHE{$host}->[0] != 0)) {
      my $rc=$SNMP_CACHE{$host}->[0];
      my $rcstr=$SNMP_CACHE{$host}->[1];
      $self->log('info',"core_snmp_get_columns::[INFO ID=$task_id] CACHE de $host=U => NOSNMP RC=$rc RCSTR=$rcstr**");
      $self->response('NOSNMP');
      return {};
   }

   @EVENT_DATA=();
   $self->err_str('[OK]');
   $self->err_num(0);

   #Proteccion frente a errores
   if ($version == 3) {
      if ($sec_level =~ /authnopriv/i) {$sec_level='authNoPriv';}
      elsif ($sec_level =~ /authpriv/i) {$sec_level='authPriv';}
      elsif ($sec_level =~ /noauthnopriv/i) {$sec_level='noAuthNoPriv';}
   }

   $SNMP::auto_init_mib=1;
   my $timeout=$self->timeout();
   my $retries=$self->retries();
   my $remote_port='161';
	my $EngineTime=time();
   my $session = new SNMP::Session( DestHost => $host, Community => $community, Version=>$version, Timeout =>$timeout,
                                    RemotePort => $remote_port, Retries => $retries, UseSprintValue => 1,
                                    SecName=>$sec_name, SecLevel=>$sec_level, 'EngineTime'=>$EngineTime,
                                    AuthProto=>$auth_proto, AuthPass=>$auth_pass, PrivProto=>$priv_proto, PrivPass=>$priv_pass);


   if (!defined($session)) {
      $rc=1;
      $rcstr='ERROR en sesion '.$SNMP::Session::ErrorStr;
      $self->err_str($rcstr);
      $self->err_num($rc);
      $self->log('warning',"core_snmp_get_columns::[WARN ID=$task_id] Error en conexion a $host/$community/$remote_port/$version [$rc:$rcstr] (Timeout=$timeout|Retries=$retries)");
      $self->response('NOSNMP');
      return {};
   }


#/usr/local/bin/snmptranslate -Tp -OS IP-MIB::ipNetToMediaTable
#+--ipNetToMediaTable(22)
#   |
#   +--ipNetToMediaEntry(1)
#      |  Index: ipNetToMediaIfIndex, ipNetToMediaNetAddress
#      |
#      +-- CR-- INTEGER   ipNetToMediaIfIndex(1)
#      |        Range: 1..2147483647
#      +-- CR-- String    ipNetToMediaPhysAddress(2)
#      |        Textual Convention: PhysAddress
#      +-- CR-- IpAddr    ipNetToMediaNetAddress(3)
#      +-- CR-- EnumVal   ipNetToMediaType(4)
#               Values: other(1), invalid(2), dynamic(3), static(4)
#

   my @cols=();
   my $dir_cache = '/opt/data/cache/mib_tables';
   if (! -d  $dir_cache) { make_path($dir_cache); }
   my $fcache = $dir_cache .'/'. $oid;
   if ((-f $fcache) && ((-s $fcache)>0)) {
      open (F,"<$fcache");
      while (<F>) {
         chomp;
         push @cols, $_;
      }
      close F;
   }
   else {

      my @lines = `/usr/local/bin/snmptranslate -Tp -OS $oid`;
      open (F,">$fcache");
      foreach my $l (@lines) {
         chomp $l;
         if ($l =~ /\+\-\-\s+\S{4}\s+\S+\s+(\S+)\(\d+\)$/) {
            push @cols,$1;
            print F "$1\n";
         }
      }
      close F;
   }

	if (scalar(@cols)==0) {
      $self->log('info',"core_snmp_get_columns::[INFO ID=$task_id] **NO EXISTE OID** oid=$oid**");
      return {};	
	}

   my @varlist=map([$_], @cols);

	# Hay que validar los resultados porque aunque el agente remoto responda a getnext
	# puede responder la primera vez con un oid diferente.
	# %validate se usa para confirmar que responde a lo que se le pregunta
	my %validate=();
   foreach my $x (@varlist) {
      $validate{$x->[0]}=0;
   }

   my $vars = new SNMP::VarList(@varlist);

   # get first row
   my @data = $session->getnext($vars);
   my %row=();
   my $idx=0;
   foreach my $i (0..scalar(@varlist)-1) {
      if (! defined $data[$i]) { next; }
      $row{$varlist[$i]->[0]} = $data[$i];
      $idx = $varlist[$i]->[1];
   }


   if ($session->{ErrorNum}!=0) {
      $rc=1;
      $rcstr='ERROR: '.$SNMP::Session::ErrorStr;
      $self->err_str($rcstr);
      $self->err_num($rc);
      $self->log('warning',"core_snmp_get_columns::[WARN ID=$task_id] Error al obtener las columnas de $host/$community/$remote_port/$version [$rc:$rcstr] (Timeout=$timeout|Retries=$retries)");
      return {};
   }


	#Se validan los resultados
   #print Dumper(\%validate);
	my $ok=0;
   foreach my $k (keys %row) {
      if (exists $validate{$k}) { 
			$ok=1;
			$validate{$k}=1; 
		}
   }
  	#print Dumper(\%validate);
   my $x = scalar(keys(%validate));
   if ($ok) { 
   	$self->log('info',"core_snmp_get_columns::[INFO ID=$task_id] cols=@cols data=@data **");
		return { $idx => \%row }; 
	}
   else { 
   	$self->log('info',"core_snmp_get_columns::[INFO ID=$task_id] **NO RESPONDE AL OID** cols=@cols data=@data **");
		return {};
	}

#   $self->log('info',"core_snmp_get_columns::[INFO ID=$task_id] cols=@cols data=@data **");
#   return { $idx => \%row };

#$VAR1 = {
#          '6' => {
#                   'ifMtu' => '1500',
#                   'ifPhysAddress' => 'PV',
#                   # ...
#                   'ifInUnknownProtos' => '0'
#                 },
#          # ...
#         };

}






#----------------------------------------------------------------------------
# Funcion: core_snmp_get
# Descripcion:
# IN:
# OUT:
# Devuelve una referencia a un vector con los datos pedidos. Si no hay respuesta
# los valores son 'U'. Pero siempre existen los valores.
# En $self->err_num y $self->err_str estan los codigos de error
#----------------------------------------------------------------------------
sub core_snmp_get  {
my ($self,$desc)=@_;
my @values=();
my ($r,$rc,$rcstr);
my $host=$desc->{host_ip};
my $oid=$desc->{oid};
my $community=$desc->{community};
my $version= (defined $desc->{version}) ? $desc->{version} : 1;
my $auth_proto = (defined $desc->{'auth_proto'}) ? $desc->{'auth_proto'} : 'MD5' ;
my $auth_pass = (defined $desc->{'auth_pass'}) ? $desc->{'auth_pass'} : '' ;
my $priv_proto = (defined $desc->{'priv_proto'}) ? $desc->{'priv_proto'} : 'DES' ;
my $priv_pass = (defined $desc->{'priv_pass'}) ? $desc->{'priv_pass'} : '' ;
my $sec_name = (defined $desc->{'sec_name'}) ? $desc->{'sec_name'} : '' ;
my $sec_level = (defined $desc->{'sec_level'}) ? $desc->{'sec_level'} : '' ;


   #-------------------------------------------------------------------
   my $task_id=$self->task_id();
	my @o=split(/\|/,$oid);
	my $num_values=scalar (@o);
	$self->response('OK');

   #-------------------------------------------------------------------
   if (( exists $SNMP_CACHE{$host}) && ($SNMP_CACHE{$host}->[0] != 0)) {
		my $rc=$SNMP_CACHE{$host}->[0];
		my $rcstr=$SNMP_CACHE{$host}->[1];
   	$self->log('info',"core_snmp_get::[INFO ID=$task_id] CACHE de $host=U => NOSNMP RC=$rc RCSTR=$rcstr**");
		$self->response('NOSNMP');
		for my $i (0..$num_values-1) { push @values, 'U'; }
		return \@values;
		#return ['NOSNMP'];
      #return undef;
   }

   #-------------------------------------------------------------------
   my $context='';
   my $remote_port='161';
	my $iid_mode='';
   if ((defined $desc->{'params'}) && ($desc->{'params'} ne '')) {

      #[{"key":"context","value":"ctxname_vsid11"}]
      my $vparams=[];
      eval { $vparams = decode_json($desc->{'params'}); };
      if ($@) {
         $self->log('warning',"core_snmp_get:: **ERROR** en decode_json de params >> $desc->{'params'} ($@)");
      }
      foreach my $l (@$vparams) {
         if ($l->{'key'} =~/context/) { $context=$l->{'value'}; }
         elsif ($l->{'key'} =~/remote_port/) { $remote_port=$l->{'value'}; }
			elsif ($l->{'key'} =~/iid_mode/) { $iid_mode=$l->{'value'}; }
      }
      $self->log('info',"core_snmp_get::[INFO ID=$task_id] CONTEXT=$context REMOTE_PORT=$remote_port IID_MODE=$iid_mode");


#     #context=context_vsid1
#     my @d=split(';', $desc->{'params'});
#     foreach my $x (@d) {
#        my ($k,$v)= split('=',$x);
#        if ($k=~/context/) { $context=$v; }
#     }
#     $self->log('info',"core_snmp_get::[INFO ID=$task_id] **CONTEXT** context>>$context");
   }


	@EVENT_DATA=();
   $self->err_str('[OK]');
   $self->err_num(0);

	#Proteccion frente a errores
   if ($version == 3) {
      if ($sec_level =~ /authnopriv/i) {$sec_level='authNoPriv';}
      elsif ($sec_level =~ /authpriv/i) {$sec_level='authPriv';}
      elsif ($sec_level =~ /noauthnopriv/i) {$sec_level='noAuthNoPriv';}
   }

	#_fml_ Parche hasta contemplar version en txml
	#if ($oid =~ /\.1\.3\.6\.1\.2\.1\.31/) { $version = 2; }
   $SNMP::auto_init_mib=0;
	my $timeout=$self->timeout();
	my $retries=$self->retries();

	# Caso particular del squid
	if ($oid =~ /\.1\.3\.6\.1\.4\.1\.3495/) { $remote_port = '3401'; }
#   my $session = new SNMP::Session (DestHost => $host,
#											RemotePort => $remote_port,
#                                 Community => $community,
#											Version=> $version,
#                                 Timeout => $timeout,
#                                 Retries => $retries);

	my $EngineTime=time();
   my $session = new SNMP::Session(	DestHost => $host, Community => $community, Version=>$version, Timeout =>$timeout,
												RemotePort => $remote_port, Retries => $retries, UseSprintValue => 1,
                              		SecName=>$sec_name, SecLevel=>$sec_level, Context=>$context, 'EngineTime'=>$EngineTime,
                              		AuthProto=>$auth_proto, AuthPass=>$auth_pass, PrivProto=>$priv_proto, PrivPass=>$priv_pass);



   if (!defined($session)) {
		$rc=1;
		$rcstr='ERROR en sesion '.$SNMP::Session::ErrorStr;
		$self->err_str($rcstr);
		$self->err_num($rc);
     # $self->log('warning',"core_snmp_get::[WARN ID=$task_id] Error en conexion a $host/$community/$remote_port/$version [$rc:$rcstr] (Timeout=$timeout|Retries=$retries)");
 		$self->log('warning',"core_snmp_get::[WARN ID=$task_id] Error en conexion a $host/$community/$remote_port/$version [$rc:$rcstr] (Timeout=$timeout|Retries=$retries) auth_proto=$auth_proto auth_pass=$auth_pass priv_proto=$priv_proto priv_pass=$priv_pass sec_name=$sec_name sec_level=$sec_level context=$context");
		$self->response('NOSNMP');
      for my $i (0..$num_values-1) { push @values, 'U'; }
      return \@values;
		#return ['NOSNMP'];
      #return undef;
   }

	my $u=0;
   foreach (@o) {

		if ($u) { $r='U'; }
		else {
			# OJO!! no funciona si se especifica el oid como nombre mib::valor (??)
			# Quizas sea alguna opcion ??
			#if ($_ =~ /^\S+?\:\:(\S+)$/) { $_=$1; }
			if ($_ =~ /^(1\.\d+\.\S+)$/) { $_='.'.$1; }
			my $var=[$_,'','',''];
			$r = $session->get($var);
			$rc=$session->{ErrorNum};
			if ($rc != 0) { $r='U'; }
			my $var_type=$var->[3];
$self->log('debug',"core_snmp_get::[ID=$task_id] ****DEBUG***** $_  >> var_type=$var_type r=$r rc=$rc");
			if ($var_type eq 'TICKS') { $r=$self->ticks2seconds($r); }
			# Si existe $desc->{'octetstr'} no convertimos a ascii. Para algun oid puede ser necesario
			elsif (($var_type eq 'OCTETSTR') && (! exists $desc->{'octetstr'})) {$r=$self->hex2ascii($r); }
$self->log('debug',"core_snmp_get::[ID=$task_id] ****DEBUG***** $_  >> var_type=$var_type r=$r rc=$rc");

			# OJO !!m si devuelve NOSUCHOBJECT  el rc=0 como si todo fuera OK (???)
			# por eso hay que comprobarlo explicitamente
   		if ($rc != 0) {
				$rcstr=$session->{ErrorStr};
				$u=1;
				$r='U';
				# En v3 un error de autenticacion debe equivaler a sin respuesta snmp
				# -35:Authentication failure (incorrect password, community or key)
				if ($rc == -35) { $self->response('NOSNMP'); } 
			   #-33:Unknown user name
   			elsif ($rc==-33) { $self->response('NOSNMP'); }

				$self->log('warning',"core_snmp_get::[WARN ID=$task_id] GET HOST=$host (V=$version OIDs=$_ C=$community Timeout=$timeout Retries=$retries) ==> $rc:$rcstr");
			}
         elsif ( ($r eq 'NOSUCHOBJECT') || ($r =~ /No Such Instance/i) || ($r =~ /No Such Object/i) )  {
            $rcstr='No existe OID/IID';
				$rc=111;
            $u=1;
            $r='U';
            $self->log('warning',"core_snmp_get::[WARN ID=$task_id] GET HOST=$host (V=$version OIDs=$_ C=$community) ==> $rc:$rcstr");
         }
         elsif ( $r =~ /Wrong Type/i )  {
            $rcstr='ERROR EN EL TIPO DE DATO REPORTADO >>'.$r;
            $rc=112;
            $u=1;
            $r='U';
            $self->log('warning',"core_snmp_get::[WARN ID=$task_id] GET HOST=$host (V=$version OIDs=$_ C=$community) ==> $rc:$rcstr");
         }

			else { $rcstr='OK'; }

         #-------------------------------------------------------------------
         # EXCEPCIONES
         # Casos en los que se espera un valor numerico pero el equipo tiene
         # definido el valor como string
         #-------------------------------------------------------------------
         # cnm:/opt/crawler/bin# snmpget -On -v 1 -c public 10.125.24.158  enterprises.7779.3.1.1.2.1.1.0
         # .1.3.6.1.4.1.7779.3.1.1.2.1.1.0 = STRING: "+24.80 C"
         #-------------------------------------------------------------------
         if (($_=~/\.1\.3\.6\.1\.4\.1\.7779\.3\.1\.1\.2\.1\.1\.0/) ||
            ($_=~/enterprises\.7779\.3\.1\.1\.2\.1\.1\.0/) ) {  $r=~s/^.*?([\d+|\.*]+).*?$/$1/;  }
         #-------------------------------------------------------------------

		}
   	push @values,$r;

		# Intento que el mensaje del evento sea lo mas amigable posible.
		my $rcstru = $rcstr;
		if ( ($rc != 0) && ($RCSTR2USER{$rc})) { $rcstru = $RCSTR2USER{$rc}; }

		push @EVENT_DATA, "RES=$rcstru OID=$_";
      $self->err_str($rcstru);
      $self->err_num($rc);
	}

	undef $session;
	return \@values;
}



#----------------------------------------------------------------------------
# Funcion: core_snmp_table_hash
#----------------------------------------------------------------------------
sub core_snmp_table_hash  {
my ($self,$desc,$timeout_max)=@_;
my @values=();

if ((!defined $timeout_max) || ($timeout_max!~/\d+/) || ($timeout_max<0)) { $timeout_max =300; }


my $host=$desc->{'host_ip'};
my $community=$desc->{'community'};
my $version=(defined $desc->{'version'}) ? $desc->{'version'} : '1' ;
my $auth_proto = (defined $desc->{'auth_proto'}) ? $desc->{'auth_proto'} : 'MD5' ;
my $auth_pass = (defined $desc->{'auth_pass'}) ? $desc->{'auth_pass'} : '' ;
my $priv_proto = (defined $desc->{'priv_proto'}) ? $desc->{'priv_proto'} : 'DES' ;
my $priv_pass = (defined $desc->{'priv_pass'}) ? $desc->{'priv_pass'} : '' ;
my $sec_name = (defined $desc->{'sec_name'}) ? $desc->{'sec_name'} : '' ;
my $sec_level = (defined $desc->{'sec_level'}) ? $desc->{'sec_level'} : '' ;

my $oid=$desc->{'oid'};
#Hay casos en los que cualificar ifTable no funciona bien
if ($oid =~ /\:\:ifTable$/) { $oid='ifTable'; }

   my $task_id=$self->task_id();
   my $err_str='[OK]';
   my $rc=0;
   $self->err_str($err_str);
   $self->err_num($rc);
   my @o=split(/\|/,$oid);
   #my $num_values=scalar (@o);

	my @o1=split(/_/,$o[0]);
   my $num_values=scalar (@o1);

	@EVENT_DATA=();
   $self->response('OK');


   if (( exists $SNMP_CACHE{$host}) && ($SNMP_CACHE{$host}->[0] != 0)) {
      $rc=$SNMP_CACHE{$host}->[0];
      $err_str=$SNMP_CACHE{$host}->[1];
      $self->err_str($err_str);
      $self->err_num($rc);

      $self->log('info',"core_snmp_table_hash::[INFO ID=$task_id] CACHE de $host=U => RES=NOSNMP RC=$rc RCSTR=$err_str**");
      $self->response('NOSNMP');
      for my $i (0..$num_values-1) { push @values, 'U'; }
      return \@values;
	}

   if ($version == 3) {
      if ($sec_level =~ /authnopriv/i) {$sec_level='authNoPriv';}
      elsif ($sec_level =~ /authpriv/i) {$sec_level='authPriv';}
      elsif ($sec_level =~ /noauthnopriv/i) {$sec_level='noAuthNoPriv';}
   }


   SNMP::initMib();
   SNMP::loadModules('ALL');
   #my $timeout=$self->timeout();
   #En este caso se pone otro valor de timeout. Se ha visto que con getbulk algunos dispositivos se
   #podian quedar en bucle con timeout=3
   my $timeout=2000000;
   my $retries=$self->retries();
   my $remote_port='161';

   #if ($oid =~ /\.1\.3\.6\.1\.4\.1\.3495/) { $remote_port = '3401'; }
	my $EngineTime=time();
   my $session = new SNMP::Session(DestHost => $host, Community => $community,
                              SecName=>$sec_name, SecLevel=>$sec_level, 'EngineTime'=>$EngineTime,
                              AuthProto=>$auth_proto, AuthPass=>$auth_pass, PrivProto=>$priv_proto, PrivPass=>$priv_pass,
                              Version=>$version, Timeout =>$timeout, RemotePort => $remote_port,
                              Retries => $retries, UseSprintValue => 1);
   if (!defined($session)) {
      $rc=1;
      $err_str='ERROR en sesion '.$SNMP::Session::ErrorStr;
      $self->err_str($err_str);
      $self->err_num($rc);
      $self->log('warning',"core_snmp_table_hash::[WARN ID=$task_id] Error en conexion a $host/$community/$remote_port/$version [$rc:$err_str] (Timeout=$timeout|Retries=$retries)");
      undef $session;
      $self->response('NOSNMP');
      for my $i (0..$num_values-1) { push @values, 'U'; }
      return \@values;
	}

	my $table;

#print "session=$session\t oid=$oid\n";

	eval {

		alarm($timeout_max);

      #Conviene especificar nogetbulk porque se han detectado equipos que pese
      #a soportar version=2 no lo implementan.
      $table=$session->gettable($oid, 'nogetbulk' => 1, noindexes => 1);

      $rc=$session->{ErrorNum};
		$err_str=$session->{ErrorStr};
      $self->err_str($err_str);
      $self->err_num($rc);

      # En v3 un error de autenticacion debe equivaler a sin respuesta snmp
      # -35:Authentication failure (incorrect password, community or key)
      if ($rc == -35) { $self->response('NOSNMP'); }
	   #-33:Unknown user name
   	elsif ($rc==-33) { $self->response('NOSNMP'); }

		$self->log('warning',"core_snmp_table_hash:: $err_str (rc=$rc)");

		alarm(0);
	};
	if ($@) { 
		$rc=1000;
		$err_str="ERROR en gettable ($@)";
      $self->err_str($err_str);
      $self->err_num($rc);
		$self->log('warning',"core_snmp_table_hash::$err_str"); 	
	}

	push @EVENT_DATA, "RES=$err_str OID=$oid";

	return $table;

}



#----------------------------------------------------------------------------
# Funcion: core_snmp_table
# Descripcion:
#
#	OUT: array compuesto por filas del tipo:  v1:@:v2....:@:vn
# 	En los metodos $self->err_str() y $self->err_num() almacena el codigo
#	y el mensaje de error obtenido.
#	Si todo ha sido correcto err_num=0 y err_str=OK
#----------------------------------------------------------------------------
sub core_snmp_table  {
my ($self,$desc)=@_;
my @values=();
my %hvalues=();
#my $timeout_max=5;
my $timeout_max=30;

my $host=$desc->{'host_ip'};
my $community=$desc->{'community'};
my $version=(defined $desc->{'version'}) ? $desc->{'version'} : '1' ;
my $auth_proto = (defined $desc->{'auth_proto'}) ? $desc->{'auth_proto'} : 'MD5' ;
my $auth_pass = (defined $desc->{'auth_pass'}) ? $desc->{'auth_pass'} : '' ;
my $priv_proto = (defined $desc->{'priv_proto'}) ? $desc->{'priv_proto'} : 'DES' ;
my $priv_pass = (defined $desc->{'priv_pass'}) ? $desc->{'priv_pass'} : '' ;
my $sec_name = (defined $desc->{'sec_name'}) ? $desc->{'sec_name'} : '' ;
my $sec_level = (defined $desc->{'sec_level'}) ? $desc->{'sec_level'} : '' ;
#----------------------------------------------------------------------------
#Ejemplos
#my $oid='ifIndex_ifDescr_ifType_ifMtu_ifSpeed';
#my $last='ifPhysAddress';
my $oid=$desc->{'oid'};
#----------------------------------------------------------------------------

   #-------------------------------------------------------------------------
   my $task_id=$self->task_id();
   my $err_str='[OK]';
   my $rc=0;
   $self->err_str($err_str);
   $self->err_num($rc);
	@EVENT_DATA=();

#my $oid="SOCOMECUPS-MIB::upsOutputVoltage";
   my @o=split(/\|/,$oid);
   #my $num_values=scalar (@o);

   my @o1=split(/_/,$o[0]);
   my $num_values=scalar (@o1);

	$self->response('OK');


#DBG--
	if ($version==3) {
		$self->log('debug',"core_snmp_table::[DEBUG ID=$task_id] V=$version U=$sec_name L=$sec_level a=$auth_proto A=$auth_pass x=$priv_proto X=$priv_pass oid=$oid**");
	}
	else  {
	   $self->log('debug',"core_snmp_table::[DEBUG ID=$task_id] V=$version C=$community oid=$oid**");
	}
#/DBG--

#my $kk=Dumper($desc);
#$self->log('debug',"core_snmp_table::[DEBUG ID=$task_id] **FML**DUMP=$kk");
#$self->log('debug',"core_snmp_table::[DEBUG ID=$task_id] **FML********o1=@o1");


	# Compruebo si el dispositivo responde por SNMP
   if (( exists $SNMP_CACHE{$host}) && ($SNMP_CACHE{$host}->[0] != 0)) {
		$rc=$SNMP_CACHE{$host}->[0];
		$err_str=$SNMP_CACHE{$host}->[1];
	   $self->err_str($err_str);
   	$self->err_num($rc);

   	$self->log('info',"core_snmp_table::[INFO ID=$task_id] CACHE de $host=U => RES=NOSNMP RC=$rc RCSTR=$err_str** num_values=$num_values");
		#return ['U'];
		$self->response('NOSNMP');
      for my $i (0..$num_values-1) { push @values, 'U'; }
      return \@values;
		#return ['NOSNMP'];
		#return undef;
	}

	#Proteccion frente a errores
	if ($version == 3) {
		if ($sec_level =~ /authnopriv/i) {$sec_level='authNoPriv';}
		elsif ($sec_level =~ /authpriv/i) {$sec_level='authPriv';}
		elsif ($sec_level =~ /noauthnopriv/i) {$sec_level='noAuthNoPriv';}
	}


   #$SNMP::auto_init_mib=1;
   SNMP::initMib();

	my $load_modules='ALL';
	if ((exists $desc->{'range'}) && ($desc->{'range'} =~ /(\S+)\:\:.*/)) { $load_modules=$1; }
   SNMP::loadModules($load_modules);
	my $timeout=$self->timeout();
	my $retries=$self->retries();
   my $remote_port='161';
   # Caso particular del squid
	#fml Esto hay que ver como se puede chequear en el core_table
   if ($oid =~ /\.1\.3\.6\.1\.4\.1\.3495/) { $remote_port = '3401'; }

	my $session = undef;
	my $EngineTime=time();
	if ( (exists $desc->{'UseEnums'}) && ($desc->{'UseEnums'}>0)) {

		$session = new SNMP::Session(DestHost => $host, Community => $community,
										SecName=>$sec_name, SecLevel=>$sec_level, 'EngineTime'=>$EngineTime,
										AuthProto=>$auth_proto, AuthPass=>$auth_pass, PrivProto=>$priv_proto, PrivPass=>$priv_pass,
                             	Version=>$version, Timeout =>$timeout, RemotePort => $remote_port,
										Retries => $retries, UseEnums => 1);
	}
	else {

      $session = new SNMP::Session(DestHost => $host, Community => $community,
                              SecName=>$sec_name, SecLevel=>$sec_level, 'EngineTime'=>$EngineTime,
                              AuthProto=>$auth_proto, AuthPass=>$auth_pass, PrivProto=>$priv_proto, PrivPass=>$priv_pass,
                              Version=>$version, Timeout =>$timeout, RemotePort => $remote_port,
                              Retries => $retries, UseEnums => 0, UseSprintValue => 1);
	}

   if (!defined($session)) {
		$rc=1;
      $err_str='ERROR en sesion '.$SNMP::Session::ErrorStr;
		$self->err_str($err_str);
		$self->err_num($rc);
      $self->log('warning',"core_snmp_table::[WARN ID=$task_id] Error en conexion a $host/$community/$remote_port/$version [$rc:$err_str] (Timeout=$timeout|Retries=$retries)");
      undef $session;
		#return ['U'];
      $self->response('NOSNMP');
      for my $i (0..$num_values-1) { push @values, 'U'; }
      return \@values;
		#return ['NOSNMP'];
      #return undef;
   }

   my $end = time + $timeout_max;
	my @vals;
	my $error_in_response=0;

   foreach my $VARLIST (@o) {

$self->log('debug',"core_snmp_table::[DEBUG ID=$task_id] **FML********(load_modules=$load_modules) VARLIST=$VARLIST");

		my %requested = map { $_=>0 } split(/_/,$VARLIST);
      my $nreq=scalar (keys %requested);

      my @varlist=map([$_],split(/_/,$VARLIST));
      my $vars = new SNMP::VarList(@varlist);
      my $mark=$varlist[0][0];
#print "MARK=$mark\n";

#DBG--
   $self->log('debug',"core_snmp_table::[DEBUG ID=$task_id] ------MIBS=$load_modules MARK=$mark VARS=@$vars varlist=@varlist VARLIST=$VARLIST O=@o**");
#/DBG--

      @vals = $session->getnext($vars);

      $rc=$session->{ErrorNum};
      # En v3 un error de autenticacion debe equivaler a sin respuesta snmp
      # -35:Authentication failure (incorrect password, community or key)
      if ($rc == -35) { $self->response('NOSNMP'); }
	   #-33:Unknown user name
   	elsif ($rc==-33) { $self->response('NOSNMP'); }



      my $do=1;
      while ($do) {
			
$self->log('debug',"core_snmp_table::[DEBUG ID=$task_id] **FML********vals=@vals");
my $kk1=Dumper($vars);
$kk1=~s/\n/  /g;
$self->log('debug',"core_snmp_table::[DEBUG ID=$task_id] **FML********vars=$kk1");

			# $vars es una ref. a objeto ARRAY que contiene los siguientes valores: <obj>,<iid>,<val>, and <type>
			# p.ej: [ 'hrStorageDescr',    '6',  'Memory buffers',      'OCTETSTR'    ]

			#------------------------------------------------------
			# Verifico que no ha habido error al obtener los datos (getnext)
			# Si fuera asi termino con error
         if ($session->{ErrorNum}) {
            my $e=$session->{ErrorStr};
            $self->log('info',"core_snmp_table::[ERROR ID=$task_id] TERMINO GETNEXT ERRORSTR=**$e**");
            $do=0;
            last;
         }

			#------------------------------------------------------
         # Valido que los oids que obtengo son los que se piden
			for my $i (0..$nreq-1) {
				my $tag_full=$vars->[$i]->tag;
				my $otype=$vars->[$i]->type;
				#  Para el chequeo de los tags no uso el nombre de la MIB
				my $tag=$tag_full;
				if ($tag_full =~ /^\S+\:\:(\S+)$/) { $tag=$1; }
				$requested{$tag}=1;

				my $iid=$vars->[$i]->iid;
				my $obj=$vars->[$i]->tag;
				my $v=$vars->[$i]->val;
				#$hvalues{$iid}->{$obj}=$v;

				$self->log('debug',"core_snmp_table::**FML** I=$i iid=$iid obj=$obj ($otype) v=$v (nreq=$nreq)");

				my $v1=&MIBTypes::chk_tag($tag,$v);
				#$hvalues{$iid}->{$obj}=$v1;
				if (($otype eq 'OCTETSTR') && (! exists $desc->{'octetstr'})) {$hvalues{$iid}->{$obj}=$self->hex2ascii($v1); }
				else { $hvalues{$iid}->{$obj}=$v1; }
			}

# obsoleto con hvalues
#			foreach my $k_full (keys %requested) {
#				my $k=$k_full;
#				if ($k=~ /^\S+\:\:(\S+)$/) { $k=$1; }
#				if ($requested{$k}==0) {
#					$error_in_response=1;
#           		$self->log('info',"core_snmp_table::[ERROR ID=$task_id] ERROR IN RESPONSE  FALTA TAG=$k");
#					#last;
#				}
#				#else { $self->log('info',"core_snmp_table::[ERROR ID=$task_id] TAG=$k  **OK**");  }
#			}
#         if ($error_in_response) {
#           	$do=0;
#				my $debug_req=Dumper(\%requested);
#				$self->log('info',"core_snmp_table::[ERROR ID=$task_id] oid=$oid o=@o");
#				$self->log('info',"core_snmp_table::[ERROR ID=$task_id] requested=$debug_req");
#          	last;
#			}
#

			#------------------------------------------------------
         if ( (time > $end) || ($vars->[0]->tag ne $mark) ) {  
				my $auxv=$vars->[0]->tag;
				$self->log('debug',"core_snmp_table::[ID=$task_id] TERMINO GETNEXT val=$auxv mark =$mark");
				$do=0; last; 
			}
	

#print "VAL=@vals\n";
#DBG--
   #$self->log('debug',"core_snmp_table::[**FML** ID=$task_id] MARK=$mark (TAG=$ff) (E=$ee) (D=$dd)**");
#/DBG--
			
         $end = time + $timeout_max;
         my $index=$vars->[0]->iid;
         if ($index !~ /\d+/) {
         	$self->log('debug',"core_snmp_table::[WARN ID=$task_id] INDEX=$index**");
            last;
         }

			#push @values, join (':@:', $index,@vals);

#DBG--
#   $self->log('debug',"core_snmp_table::[DEBUG ID=$task_id] MARK=$mark INDEX=$index==");
#/DBG--

         @vals = $session->getnext($vars);
      }
	}

#my $kk3=Dumper(\@o1);
#$kk3=~s/\n/\.  /g;
#$self->log('debug',"core_snmp_table::[DEBUG ID=$task_id] **FML*** o1>>>$kk3");
#my $kk2=Dumper(\%hvalues);
#$kk2=~s/\n/  /g;
#$self->log('debug',"core_snmp_table::[DEBUG ID=$task_id] **FML*******hvalues=$kk2");

	@values=();
	foreach my $iid (sort keys %hvalues) {
		my @x=();
		my $c=0;
		foreach my $col (@o1) {
			if (exists $hvalues{$iid}->{$col}) { push @x,$hvalues{$iid}->{$col}; $c+=1; }
			else {
				push @x,'U'; 
				$self->log('debug',"core_snmp_table::[$task_id] FALTA COLUMNA EN TABLA iid=$iid col=$col");
			}	
		}
		if ($c>0) {
			push @values, join (':@:', $iid,@x);
		}
	}

#my $kk3=Dumper(\@values);
#$kk3=~s/\n/  /g;
#$self->log('debug',"core_snmp_table::[DEBUG ID=$task_id] **FML*******hvalues=$kk3");

	if ( (scalar(@values)==0) && ($session->{ErrorNum} != 0 ) ) {
	#if ($session->{ErrorNum} != 0 ) {
      $rc=$session->{ErrorNum};
      $err_str=$session->{ErrorStr};
      $self->err_str($err_str);
      $self->err_num($rc);
      $self->log('warning',"core_snmp_table::[WARN ID=$task_id] ERROR = $rc ($err_str) HOST=$host num_values=$num_values version=$version");
      undef $session;
      for my $i (0..$num_values-1) { push @values, 'U'; }
   	return \@values;
      #return ['U'];
   }
#	elsif ( ( scalar(@values)==0 ) || ($error_in_response) ) {
#		$rc=1023;
#		$err_str="[WARN ID=$task_id] Respuesta invalida del dispositivo";
#     	$self->err_str($err_str);
#      $self->err_num($rc);
#      undef $session;
#      for my $i (0..$num_values-1) { push @values, 'U'; }
#      $self->log('warning',"core_snmp_table::[WARN ID=$task_id] ERROR (zeroDotZero) VALUES=@values HOST=$host num_values=$num_values (VALS=@vals)");
#      return \@values;
#   }


   if ( time > $end) {
		$rc=1024;
		$err_str="[WARN ID=$task_id] Timeout en busqueda de OID=$oid";
      $self->err_str($err_str);
      $self->err_num($rc);
      $self->log('warning',"core_snmp_table::$rc:$err_str");
   	undef $session;
      for my $i (0..$num_values-1) { push @values, 'U'; }
      return \@values;
      #return ['U'];
   }

	push @EVENT_DATA, "RES=$err_str OID=$oid";

   undef $session;
   return \@values;

}

#----------------------------------------------------------------------------
# Funcion: core_snmp_trap
# Descripcion:
#----------------------------------------------------------------------------
sub core_snmp_trap  {
my ($self,$desc)=@_;
my @values=();
my $err_str;
#16324

   #-------------------------------------------------------------------------
   my $task_id=$self->task_id();

	my $host=$desc->{host_ip};
	my $community=$desc->{community};
	my $version= '1' ; # Por ahora solo version 1
	#----------------------------------------------------------------------------

	SNMP::initMib();
	SNMP::loadModules( 'CNM-NOTIFICATIONS-MIB',);
	my $timeout=$self->timeout();
	my $retries=$self->retries();
   my $session = new SNMP::Session(DestHost => $host,
                                 Community => $community,
                                 Version=>$version,
                                 RemotePort=>'162',
                                 Timeout =>$timeout,
                                 Retries => $retries);

   if (!defined($session)) {
		$err_str='ERROR en sesion '.$SNMP::Session::ErrorStr;
      $self->err_str($err_str);
      $self->log('warning',"core_snmp_trap::[WARN ID=$task_id] Error en conexion a $host/$community/$version [$err_str] (Timeout=$timeout|Retries=$retries)");
      undef $session;
      return undef;
   }

	my $txt=$desc->{txt};
	my $enterprise='.1.3.6.1.4.1.16324';
	#my $agent='127.0.0.1';
	my $agent=my_ip();

  	$session->trap(	enterprise=> $enterprise,
               	agent =>$agent,
                	generic => 6,
                	specific => 10205,
                	uptime => 1234,
						['cnmServiceResponse', 10205, $txt ]);

	my $rc=$session->{ErrorNum};
	if ($rc != 0) { $self->log('warning',"core_snmp_trap::[WARN ID=$task_id] Error en envio a $host/$community [$rc : $err_str]"); }
	return $rc;

}


#----------------------------------------------------------------------------
# Funcion: core_snmp_trap_ext
# Descripcion:
#----------------------------------------------------------------------------
sub core_snmp_trap_ext  {
my ($self,$desc,$trap_desc)=@_;
my @values=();
my $err_str;

   #-------------------------------------------------------------------------
   my $task_id=$self->task_id();

   my $host=$desc->{'host_ip'};
   my $community=$desc->{'community'};
   my $version = $desc->{'version'} || '1' ;
	my $agent = $desc->{'agent'} || my_ip();
   #----------------------------------------------------------------------------

   SNMP::initMib();
	SNMP::loadModules('ALL');
   my $timeout=$self->timeout();
   my $retries=$self->retries();
   my $session = new SNMP::Session(	DestHost => $host,  Community => $community, Version=>$version,
												RemotePort=>'162', Timeout =>$timeout, Retries => $retries);

   if (!defined($session)) {
      $err_str='ERROR en sesion '.$SNMP::Session::ErrorStr;
      $self->err_str($err_str);
      $self->log('warning',"core_snmp_trap_ext::[WARN ID=$task_id] Error en conexion a $host/$community/$version [$err_str] (Timeout=$timeout|Retries=$retries)");
      undef $session;
      return undef;
   }

   my $enterprise=$trap_desc->{'enterprise'};
   my $specific=0;
	if ($version==1) { $specific=$trap_desc->{'specific'}; } 
   my $vardata=$trap_desc->{'vardata'};
   #my $agent='127.0.0.1';

	if ($version==1) {
	   $session->trap (	enterprise=> $enterprise, agent =>$agent, generic => 6, specific => $specific, uptime => 1234, $vardata);
	}
	else {
		# En v2 el OID del trap se pasa en el campo enterprise
		$session->trap (oid => $enterprise,  uptime => 1234, $vardata);
	}

   my $rc=$session->{ErrorNum};
   if ($rc != 0) { $self->log('warning',"core_snmp_trap_ext::[WARN ID=$task_id] Error en envio a $host/$community [$rc : $err_str]"); }
$self->log('warning',"core_snmp_trap_ext:: enterprise=> $enterprise, agent =>$agent, generic => 6, specific => $specific ($rc)");
   return $rc;

}

#----------------------------------------------------------------------------
sub get_oid_type  {
my ($self,$oid)=@_;

   SNMP::initMib();
   SNMP::loadModules('ALL');

   return &SNMP::getType($oid);

}


#----------------------------------------------------------------------------
# Funcion: _oid_prepare
# Convierte oids numericos o en formato full (mib::algo)y separados por "|" a oids
# textuales separados por "_". 
# Si esta conversion no funciona bien, las metricas tipo tabla (cfg=2) fallan.
# IN: El campo oid de la base de datos.
# 		El oid puede tener un formato inicial:.1.3.6.1.2.1.2.2.1.10.11|.1.3.6.1.2.1.2.2.1.16.11
# 		o tambien RFC1213-MIB::ifInUcastPkts|RFC1213-MIB::ifOutUcastPkts
# 		Hay que convertirlo a ifDescr_ifInOctets_ifOutOctets
#
# OUT: Valor de retorno:
#		Si OK: Un escalar del tipo ifDescr_ifInOctets_ifOutOctets
#		Si error: undef
#	
#----------------------------------------------------------------------------
sub _oid_prepare   {
my ($self,$oidi)=@_;

	my @oid_out=();
	my $error=0;
   my ($oid,$oid_name)=('',undef);
	my $task_id=$self->task_id();	
   my @oid_in=split(/\|/,$oidi);

#DBG--
   $self->log('debug',"_oid_prepare::[DEBUG ID=$task_id] INPUT=$oidi (@oid_in)");
#/DBG--

   foreach my $oid (@oid_in) {

		# El oid puede tener varios formatos numericos:
		# 1. .1.3.6.1.2.1.2.2.1.10.IID -> En este caso esta perfectamente definido oid+iid
		# 2. .1.3.6.1.2.1.2.2.1.10.11 -> En este caso NO esta definida cual es la parte oid.
		# Por eso luego hay que usar una regexp en lugar de usar la igualdad.

      #if ($v=~/^(.*)\.IID$/) { $oid=$1; }
      #else { $oid=$v; }

		# -------------------------------------------------------------
      # Ahora buscamos el oid_name de dicho oid

		# Si el oid no es numerico asumimos que ya es un oid_name
		# En caso contrario, buscamos el mapeo en la BBDD.
      #if ($oid !~ /^([\d+|\.+]+)$/) {  $oid_name=$oid; }
		
		# Solo se excluyen los casos de metricas especiales tipo:
		# hrSWRunName_hrSWRunPerfCPU_hrSWRunPerfMem
		$oid_name=$oid;
      if ($oid =~ /^([\w+|_+]+)$/) {  $oid_name=$oid; }
      else {

         my @keys= keys %OID2TXT;

         foreach my $k1 (@keys) {
#DBG--
        		#$self->log('debug',"_oid_prepare::[DEBUG ID=$task_id] COMPARO CLAVE $oid con $k1 **");
#/DBG--
           # if ($k1 eq $oid) { $oid_name=$OID2TXT{$k1}; last; }
			  # Valido que la clave es correcta no sea que haya un error en el fichero de mapeos 
				#if ($oid =~ /^1\./) { $oid ='.'.$oid; } 
				if (($k1 !~ /^\.1\.3\.6/) && ($k1 !~ /^1\.3\.6/)) { next; }
				if ($oid =~ /^$k1[\.*|\w*]*/) { $oid_name=$OID2TXT{$k1}; last; }
         }
      }

#DBG--
      $self->log('debug',"_oid_prepare::[INFO ID=$task_id] OID SOLICITADO=$oid OID_NAME=$oid_name**");
#/DBG--
		# Importante chequear si se ha encontrado el oid_name antes de insertar en el array
		if (defined $oid_name) {  push @oid_out,$oid_name;  }
		else {
			$error=1;
			last;
		}
	}

	if ($error) { return undef; }
	else {
		my $out=join('_',@oid_out);
		$self->log('debug',"_oid_prepare::[INFO ID=$task_id] IN=$oidi OUT=$out**");
		#return join('_',@oid_out);
		return $out;
	}

}


#----------------------------------------------------------------------------
# Funcion: _get_oid_mapping
# DESCRIPTION: Obtiene el mapeo oid -> oid_name a partir de los datos almacenados en
#	la tabla cfg_monitor_snmp
#	Emplea una consulta:
#		select distinct oid,oidn from cfg_monitor_snmp where oid like '%IID';
#	Con un resultado:
#		oid=.1.3.6.1.2.1.25.2.3.1.4.IID|.1.3.6.1.2.1.25.2.3.1.5.IID|.1.3.6.1.2.1.25.2.3.1.6.IID
#		oidn=hrStorageAllocationUnits.IID|hrStorageSize.IID|hrStorageUsed.IID
# OUT:
# 	El parametro $oid2txt es una referencia a un hash con los datos del mapeo oid -> oidn
#
#	%OID2TXT =(
#
# 		'.1.3.6.1.2.1.25.2.3.1.4' => 'hrStorageAllocationUnits',
#   	'.1.3.6.1.2.1.25.2.3.1.5' => 'hrStorageSize',
#   	'.1.3.6.1.2.1.25.2.3.1.6' => 'hrStorageUsed',
#			.............
#	);
#
#----------------------------------------------------------------------------
sub _get_oid_mapping   {
my ($self,$oid2txt)=@_;

   my $store=$self->store();
   my $dbh=$store->open_db();
   $self->dbh($dbh);

   my $rres=$store->get_from_db( $dbh, 'distinct oid,oidn', 'cfg_monitor_snmp', "oid like \'%IID\'");
	my $rc=$store->error();
	if ($rc) {
		my $rcstr=$store->errorstr();
		my $cmd=$store->lastcmd();
		$self->log('info',"_get_oid_mapping::[ERROR] RC=$rc ($rcstr)");
		$self->log('info',"_get_oid_mapping::[ERROR] CMD=$cmd");
		# FML EN ESTE CASO HAY QUE DECIDIR SI SE REINTENTA O SE MUERE !!!!
	}

	foreach my $l (@$rres) {
		my @oid=split(/\|/,$l->[0]);
		my @oidn=split(/\|/,$l->[1]);
		my $n=scalar @oid;
		for my $i (0..$n-1) {
			$oid[$i] =~ s/\.IID//g;
			$oidn[$i] =~ s/\.IID//g;
      	# Se contempla el caso en que la tabla contenga entradas del tipo: RFC1213-MIB::ifInUcastPkts
			#$oidn[$i] =~ s/^\S+\:\:(\S+)$/$1/g;

			# Si el oid no tiene valor (en BBDD hay algo como .IID) lo salto
			if ($oid[$i] eq '') { next; }

			# Si el oidn que obtengo es numerico, lo salto porque no me aporta info para obtener los
			# datos via core_snmp_table
			#if ($oidn[$i] =~ /[\d+|\.+]+/) { next; }
			if ($oidn[$i] =~ /(\d+\.+)+/) { next; }

			$oid2txt->{$oid[$i]} = $oidn[$i];
		}
   }

#DBG--
	my $task_id=$self->task_id();
	while (my ($k,$v) = each %$oid2txt) {
      $self->log('debug',"_get_oid_mapping::[DEBUG ID=$task_id] KEY=$k => VAL=$v");
	}
#/DBG--

}

#----------------------------------------------------------------------------
# Funcion: safe_snmpwalk
# Descripcion:
#----------------------------------------------------------------------------
sub safe_snmpwalk  {
my ($self,$cmd)=@_;

   my $MAX_REPETITIONS=100;
   my @r=();
   my $line_1='';
   my $cnt=0;
   my $pid = open(F, "$cmd|");
   while (<F>) {
      chomp;
      push @r,$_;
      if ($_ eq $line_1) { $cnt +=1; }
      else { $line_1 = $_; $cnt =0; }
      if ($cnt > $MAX_REPETITIONS) {
         $self->log('warning',"safe_snmpwalk::**SNMPWALK MIB LOOP ERROR PID=$pid cnt=$cnt** $cmd");
         kill 9,$pid;
         return [];
         #last;
      }
   }
   close(F);
   return \@r;
}

#----------------------------------------------------------------------------
# Funcion: ticks2seconds
# DISMAN-EVENT-MIB::sysUpTimeInstance = Timeticks: (616309123) 71 days, 7:58:11.23
# 71:8:02:36.77
# 71*24*3600=6134400
# 7*3600		=  25200
# 58*60		=	 3480
# 11			=		11
#----------------------------------------------------------------------------
sub ticks2seconds   {
my ($self,$val)=@_;

	my $tval=0;
	my @v=split (/\:/,$val);
	if (scalar @v == 4) { $tval=$v[0]*86400+$v[1]*3600+$v[2]*60+int($v[3]); }
	elsif (scalar @v == 3) { $tval=$v[0]*3600+$v[1]*60+int($v[2]); }
	elsif (scalar @v == 2) { $tval=$v[0]*60+int($v[1]); }
	elsif (scalar @v == 1) { $tval=int($v[0]); }
	
	$self->log('debug',"ticks2seconds::VAL=$val TVAL=$tval");	

	return $tval;



}

#----------------------------------------------------------------------------
#----------------------------------------------------------------------------
#----------------------------------------------------------------------------

#----------------------------------------------------------------------------
# Funcion: ext_fx
# Funcion generica para combinar los iids a values.
# El campo module sera del tipo:
# mod_snmp_get_ext:ext_fx(  [(o1/o2)*100]:[(o1/o2)*1000]  )
#----------------------------------------------------------------------------
sub ext_fx  {
my ($self,$val,$params)=@_;


# ej. v1=total, v2=usado
# r1=v2/v1*100
#[$size, $used]

	#[(o1/o2)*100]:[(o1/o2)*1000]
	my @res=split(/\:/,$params);
	
	my @result=();
	foreach my $fx (@res) {

		$fx =~ s/\[\s*(.+)\s*\]/$1/;
		
$self->log('debug',"ext_generic::**DEBUG** PROCESO FX=$fx** VAL=@$val");
  	 	# Substitucion de vx por los valores del array ----------
   	for my $i (1..10) {
      	my $j=$i-1;
      	if ($fx =~ /o$i/i) {
				if ($val->[$j] eq "") { $val->[$j]=0; }
         	$fx =~ s/o$i/$val->[$j]/ig;
      	}
   	}

$self->log('debug',"ext_generic::**DEBUG** PROCESADO FX=$fx**");

		my $rc=0;
   	if ($fx =~ /(.+)/) {
			if ($fx =~ /U/) { $rc = 'U'; }
      	else { $rc = eval $1; }
   	}

$self->log('debug',"ext_generic::**DEBUG** RESULTADO RC=$rc**");
		push @result, $rc;
	}

	$MITEMS = scalar @result;

	return \@result;
}


#----------------------------------------------------------------------------
# Funcion: ext_status_if
# Descripcion:
#----------------------------------------------------------------------------
sub ext_status_if  {
my ($self,$val,$params)=@_;

#[up, admin_down, down, unk]
use constant SNMP_UPi=>1;
use constant SNMP_DOWNi=>2;
use constant SNMP_UP=>'up';
use constant SNMP_DOWN=>'down';

	$MITEMS=4;
   my ($admin,$oper) = ($val->[0], $val->[1]);

#DBG--
   my $task_id=$self->task_id();
   $self->log('debug',"ext_status_if::[DEBUG ID=$task_id] admin=$admin oper=$oper**");
#/DBG--

   if ( ($admin eq 'U') || ($oper eq 'U') ) { return [0,0,0,1]; }
   if ( ($admin eq '') || ($oper eq '') ) { return [0,0,0,1]; }

	if ($admin =~ /^[0-9]+$/) {
      if ($admin == SNMP_DOWNi) {return [0,1,0,0]; }
      elsif (($admin == SNMP_UPi) && ($oper == SNMP_DOWNi)) {return [0,0,1,0]; }
      elsif (($admin == SNMP_UPi) && ($oper == SNMP_UPi))  {return [1,0,0,0]; }
      else {return [0,0,0,1]; }
	}

	else {
	   if  ($admin eq SNMP_DOWN) {return [0,1,0,0]; }
   	elsif  (($admin eq SNMP_UP) && ($oper eq SNMP_DOWN)) {return [0,0,1,0]; }
   	elsif  (($admin eq SNMP_UP) && ($oper eq SNMP_UP)) {return [1,0,0,0]; }
   	else {return [0,0,0,1]; }
 	}
}

#----------------------------------------------------------------------------
# Funcion: ext_brocade_status_port
# Descripcion:
#----------------------------------------------------------------------------
sub ext_brocade_status_port  {
my ($self,$val,$params)=@_;

#[up, admin_down, down, unk]
#use constant BP_UNK=>0;
#use constant BP_UP=>1;
#use constant BP_DOWN=>2;
#use constant BP_TEST=>3;

use constant BP_UNK=>'unknown';
use constant BP_UP=>'up';
use constant BP_DOWN=>'down';
use constant BP_TEST=>'test';

	$MITEMS=4;
   my ($admin,$oper) = ($val->[0], $val->[1]);

#DBG--
	my $task_id=$self->task_id();
   $self->log('debug',"ext_brocade_status_port::[DEBUG ID=$task_id] admin=$admin oper=$oper**");
#/DBG--

   if ( ($admin eq 'U') || ($oper eq 'U') ) { return [0,0,0,1]; }
   if ( ($admin eq '') || ($oper eq '') ) { return [0,0,0,1]; }

   if ($admin eq BP_DOWN) {return [0,1,0,0]; }
   elsif (($admin eq BP_UP) && ($oper eq BP_DOWN)) {return [0,0,1,0]; }
   elsif (($admin eq BP_UP) && ($oper eq BP_UP)) {return [1,0,0,0]; }
   else {return [0,0,0,1]; }

}


#----------------------------------------------------------------------------
# Funcion: ext_mibhost_disk
# Descripcion:
#----------------------------------------------------------------------------
sub ext_mibhost_disk  {
my ($self,$val,$params)=@_;

#[$size, $used]

	$MITEMS=2;
   my ($units,$size,$used) = ($val->[0], $val->[1], $val->[2]);

	$units=~s/(\d+)\s*\w*/$1/;
	$size=~s/(\d+)\s*\w*/$1/;
	$used=~s/(\d+)\s*\w*/$1/;

#DBG--
	my $task_id=$self->task_id();
   $self->log('debug',"ext_mibhost_disk::[DEBUG ID=$task_id] units=$units size=$size used=$used**");
#/DBG--

	if ( ($units eq 'U') || ($size eq 'U') || ($used eq 'U')) { return ['U', 'U']; }

	if ((!$val->[0]) || ($val->[0] eq "")) {$units=0;}
	if ((!$val->[1]) || ($val->[1] eq "")) {$size=0;}
	if ((!$val->[2]) || ($val->[2] eq "")) {$used=0;}
	$size *= $units;
	$used *= $units;
   return [$size, $used];

}


#----------------------------------------------------------------------------
# Funcion: ext_novell_nw_disk_usage
# Descripcion:
#----------------------------------------------------------------------------
sub ext_novell_nw_disk_usage  {
my ($self,$val,$params)=@_;

#[$size, $used]

	$MITEMS=2;
   my ($total,$free,$freeable) = ($val->[0], $val->[1], $val->[2]);

   $total=~s/(\d+)\s*\w*/$1/;
   $free=~s/(\d+)\s*\w*/$1/;
   $freeable=~s/(\d+)\s*\w*/$1/;

#DBG--
	my $task_id=$self->task_id();
   $self->log('debug',"ext_novell_nw_disk_usage::[DEBUG ID=$task_id] total=$total free=$free freeable=$freeable**");
#/DBG--

   if ( ($total eq 'U') || ($free eq 'U') || ($freeable eq 'U')) { return ['U', 'U']; }

   if ((!$val->[0]) || ($val->[0] eq "")) {$total=0;}
   if ((!$val->[1]) || ($val->[1] eq "")) {$free=0;}
   if ((!$val->[2]) || ($val->[2] eq "")) {$freeable=0;}

	my $used=$total - $free - $freeable;	
   return [$total, $used];

}


#----------------------------------------------------------------------------
# Funcion: ext_status_cm_aserv
# Descripcion:
#----------------------------------------------------------------------------
sub ext_status_cm_aserv  {
my ($self,$val,$params)=@_;

#[up, admin_down, down, unk]
#[C_OK, C_DESC, C_OOS_CMD/C_OOS_DISP, resto]
use constant C_DESC=>1;
use constant C_ARRANQUE=>2;
use constant C_OK=>3;
use constant C_OOS_DISP=>4;
use constant C_OOS_CMD=>5;
use constant C_IS=>6;
use constant C_ACTUALIZ=>7;
use constant C_SIN_SES=>8;
use constant C_ANUL=>9;
use constant C_APAG=>10;

	$MITEMS=4;

#DBG--
   my $task_id=$self->task_id();
   $self->log('debug',"ext_status_cm_aserv::[DEBUG ID=$task_id] valor=$val->[0]**");
#/DBG--

	if ($val->[0] == 3) { return [1,0,0,0]; }
	elsif ($val->[0] == 1) {return [0,1,0,0]; }
	elsif ( ($val->[0] == 4) || ($val->[0] == 5) ) {return [0,1,0,0]; }
	else {return [0,0,0,1]; }

}



#----------------------------------------------------------------------------
#----------------------------------------------------------------------------
# METRICAS SNMP ESPECIALES
# 	Son metricas que requieren uno o varios parametros introducidos por el usuario
#	del tipo que sea (cadena de texto ...)
#	Se calculan a partir de un walk  realizando una logica adicional.
#
#	INCLUSION DE NUEVAS METRICAS:
# 	Para validar una nueva metrica SNMP especial hay que hacer lo siguiente:
#
#	1. Debe existir en la libreria de metricas especiales la funcion adecuada
#		para calcular la metrica buscada.
#		Si no existiera, lo primero seria crearla. Si existe una funcion valida vamos al punto 2.
#
#	2.	Se debe crear la definicion en B.D (tabla cfg_monitor_esp)
#		==> Vector $CFG_MONITOR_SNMP_ESP en /var/www/html/onm/db/Init/DB-Scheme-Init-snmp.php
#
#      array(
#         'name' => 'esp_proc_mibhost',
#         'description' => 'MONITORIZAR UN PROCESO CONCRETO',
#         'info' => 'HOST-RESOURCES-MIB|hrSWRunName|OCTET STRING (0..64)|A textual description of this running piece of software, including the manufacturer, revision,  and the name by which it is commonly known. If this software was installed locally, this should be the same string as used in the corresponding hrSWInstalledName. Mide el numero de ocurrencias del proceso especificado en la tabla descrita.',
#         'oid' => 'hrSWRunName',
#         'class' => 'MIB-HOST',
#         'module' => 'mod_snmp_walk',
#         'fx' => 'match',
#         'get_iid' => '1',
#         'items' => 'Num. Procesos',
#         'vlabel' => 'num',
#         'label' => 'Proceso',
#         'mode' => 'GAUGE',
#         'mtype' => 'STD_BASEIP1',
#      ),
#

#      array(
#         'name' => 'esp_vmware_vm_mem',
#         'description' => 'VMWARE: MEMORIA EN MAQUINA VIRTUAL',
#         'info' => 'VMWARE-VMINFO-MIB|vmIdx_vmVMID_vmDisplayName|OCTET STRING (0..64)|A textual description of this running piece of software, including the manufacturer, revision,  and the name by which it is commonly known. If this software was installed locally, this should be the same string as used in the corresponding hrSWInstalledName. Mide el numero de ocurrencias del proceso especificado en la tabla descrita.',
#         'oid' => 'vmIdx_vmVMID_vmDisplayName',
#         'class' => 'VMWARE-VMINFO-MIB',
#         'module' => 'mod_snmp_walk',
#         'fx' => 'subkey(cpuUtil)',
#         'get_iid' => '1',
#         'items' => 'cpuUtil',
#         'vlabel' => 'Porc',
#         'label' => 'Uso de CPU',
#         'mode' => 'GAUGE',
#         'mtype' => 'STD_BASEIP1',
#      ),
#
#	3. Se configura la matrica snmp especial desde el interfaz. (Se configura con un string concreto
#		de modo que pase al repositorio). Con el subtype generado se valida con:
#
#		/opt/crawler/bin/libexec/chk_metric -d 192.168.55.20  -s custom_fb4c1947 -c public -l debug
#
#	4.	Si funciona todo lo anterior se valida con los procesos crawler.
#
#----------------------------------------------------------------------------
#----------------------------------------------------------------------------


#----------------------------------------------------------------------------
# Funcion: core_snmp_esp
# Descripcion:
# IN:
#		$desc:		Vector de datos de configuracion
#		$task_id:	ID de Tarea. module_name + ip
#		$values:		Resultado del walk
# RC:
#	
#----------------------------------------------------------------------------
sub core_snmp_esp  {
my ($self,$desc,$task_id,$values)=@_;


	my $result = scalar @$values;;
	# Si no hay una funcion de metrica especial. Terminamos y $result contiene
	# el numero de elementos del array
	if (! defined $desc->{'ext_function'}) { return $result; }

   # match(AFP\.NLM)(txt=1;v1=2) ==> $1=match $2=AFP\.NLM $3=txt=1;v1=2
   # avg(.*)(txt=1;v1=2) ==> $1=avg $2=AFP\.NLM $3=txt=1;v1=2
   # ordinal_iid()(v1=2) ==> $1=ordinal_iid $2=   $3=v1=2
   #$desc->{'ext_function'}=~/^\s*([^\)]+)\((.*)\)\((.+)\)\s*$/;
   #$desc->{'ext_function'}=~/^\s*([^\)]+)\(([^\)*]*)\)\(*([^\)*]*)\)*\s*$/;
   $desc->{'ext_function'}=~ /^\s*([^\(]+)\((.*?)\)\((.*?)\)$/;
   my $fx=$1;
   my $param=$2;
   my $iparam=$3;


#DBG--
	my $hname = (exists $desc->{host_name}) ? $desc->{host_name} : $desc->{hname};
   $self->log('info',"core_snmp_esp::[DEBUG ID=$task_id] name=$hname oid=$desc->{oid}**");
   $self->log('debug',"core_snmp_esp::[DEBUG ID=$task_id] extf=$desc->{ext_function} F=$fx P=$param**");
   $self->log('debug',"core_snmp_esp::[DEBUG ID=$task_id] RES DEL WALK=@$values**");
#/DBG--


   #----------------------------------
   if ($fx eq 'match') { $result=$self->esp_fx_match ($task_id,$desc,$param,$iparam,$values); }
   elsif ($fx eq 'sum') { $result=$self->esp_fx_sum ($task_id,$desc,$param,$iparam,$values); }
   elsif ($fx eq 'avg') { $result=$self->esp_fx_avg ($task_id,$desc,$param,$iparam,$values); }
   elsif ($fx eq 'subkey') { $result=$self->esp_fx_subkey ($task_id,$desc,$param,$iparam,$values); }
   elsif ($fx eq 'ordinal_iid') { $result=$self->esp_fx_ordinal_iid ($task_id,$desc,$param,$iparam,$values); }

   else {
      #realmente esto es un fallo (funcion no soportada) !!
		$self->log('warning',"core_snmp_esp::[ERROR ID=$task_id] fx=$fx param=$param FUNCION ESP_FX NO DEFINIDA");
      my $res = scalar @$values;
      #$result = [ $res ] ;
      $result =  $values ;
   }

#DBG--
   $self->log('debug',"core_snmp_esp::[DEBUG ID=$task_id] RES DE ESP_FX=@$result**");
#/DBG--

	return $result;

}


#----------------------------------------------------------------------------
# Funcion: esp_fx_match
# Descripcion:
#
#	Sobre los valores devueltos por el walk de una tabla subre un campo.
#	Hace una comprobacion de patrones y devuelve el numero de veces que la
#	comprobacion es correcta.
#	P.ej: Contar el numero de procesos llamados xxx ($param).
#
#	mod_snmp_walk:match(svchost\.exe)
#
# IN:
#     $desc:      Vector de datos de configuracion
#     $task_id:   ID de Tarea. module_name + ip
#     $values:    Resultado del walk
# OUT:
#		Devuelve el resultado [$result]
#		Es una referencia a un ARRAY
#----------------------------------------------------------------------------
sub esp_fx_match  {
my ($self,$task_id,$desc,$param,$iparam,$values)=@_;

	$MITEMS=1;
   my $result=0;
	if ((! $param) || ($param eq '*')) {
		$result = scalar @$values;
		return [$result];
	}

	#------------------------------------------------------
	#Parsing de $iparam p.ej: txt=1;v1=2 (porque iid=0)
	my @i=split(';',$iparam);
	my %ipar=();
	foreach my $x (@i) {
		my ($k,$v)=split('=',$x);
		$ipar{$k}=$v;
	}
	my $txt_index=$ipar{'txt'};

#DBG--
   $self->log('debug',"esp_fx_match::[DEBUG ID=$task_id] IPARAMS=$iparam TXT_INDEX=$txt_index param=$param**");
#/DBG--

	#------------------------------------------------------
	# Se eliminan las barras invertidas del patron especificado.
	# OJO. Los espacios no pueden codificarse como \s+
   my $pattern=$param;
   $pattern =~ s/\\//g;
   $pattern =~ s/\*/\.\*\?/g;

   foreach my $l (@$values) {
      ## OJO El primer valor es el iid !!
      #my ($id,$v)=split(':@:',$l);
      #if ($v=~ /$pattern/i) {$result += 1; }

		if ($l eq 'U') {next; }
		# El indice del pattern viene dado por el $ipar{'txt'}
		my @P=split(':@:',$l);
#DBG--
#   $self->log('debug',"esp_fx_match::[DEBUG ID=$task_id] result=$result PARAM_TXT=$P[$txt_index] PATTERN=$pattern L=$l**");
#/DBG--

		# Se quitan las comillas al valor obtenido.
		$P[$txt_index] =~ s/^"(.+)"$/$1/g;
		$P[$txt_index] =~ s/^'(.+)'$/$1/g;
	
   $self->log('debug',"esp_fx_match::[DEBUG ID=$task_id] COMPARO P=$P[$txt_index] CON uc pattern=$pattern--");
#COMPARO P=NDPSM.NLM    v3.02d (20080609) CON uc pattern=ndpsm.nlm**

      #if ($P[$txt_index]=~ /\b$pattern\b/i) {$result += 1; }

		if ($pattern =~ /\*/) {
			if ($P[$txt_index]=~ /$pattern/i) {$result += 1; }
		}
		else {
	      if ((uc $P[$txt_index] eq uc $pattern) || $pattern eq '.*') {$result += 1; }
		}
   }
	#return $result;
	return [$result];

}


#----------------------------------------------------------------------------
# Funcion: esp_fx_avg
# Descripcion:
#
#  Sobre los valores devueltos por el walk de una tabla subre un campo.
#  Hace una comprobacion de patrones y devuelve la media aritmetica del valor asociado
#	al patron que se esta comprobando.
#  P.ej: Sumar la memoria/cpu de un determinado proocesos llamado xxx ($param).
#
#  mod_snmp_walk:avg(svchost\.exe)
#
# IN:
#     $desc:      Vector de datos de configuracion
#     $task_id:   ID de Tarea. module_name + ip
#     $values:    Resultado del walk
# OUT:
#     Devuelve el resultado ($result)
#----------------------------------------------------------------------------
sub esp_fx_avg  {
my ($self,$task_id,$desc,$param,$iparam,$values)=@_;

	$MITEMS=1;
   my $result=0;
   if ((! $param) || ($param eq '*')) {
		$result = scalar @$values;
		return [$result];
	}

   #------------------------------------------------------
   #Parsing de $iparam p.ej: txt=1;v1=2 (porque iid=0)
   my @i=split(';',$iparam);
   my %ipar=();
   foreach my $x (@i) {
      my ($k,$v)=split('=',$x);
      $ipar{$k}=$v;
   }
   my $txt_index=$ipar{'txt'};
   my $v1_index=$ipar{'v1'};

   #------------------------------------------------------
   my $pattern=$param;
   $pattern =~ s/\\//g;
   $pattern =~ s/\*/\.\*\?/g;

	my $N=0;
   foreach my $l (@$values) {
      ## OJO El primer valor es el iid !!
      #my ($id,$v1,$v2)=split(':@:',$l);
      #if ($v1=~ /$pattern/i) {$result += $v2; }

      # El indice del pattern viene dado por el $ipar{'txt'}
      my @P=split(':@:',$l);

      $P[$txt_index] =~ s/^"(.+)"$/$1/g;
      $P[$txt_index] =~ s/^'(.+)'$/$1/g;

   #$self->log('debug',"esp_fx_avg::[DEBUG ID=$task_id] pattern=$pattern P=$P[$txt_index]**");

      #if ($P[$txt_index]=~ /$pattern/i) {$result += $P[$v1_index]; $N++; }
		#if ((uc $P[$txt_index] eq uc $pattern) || $pattern eq '.*') { $result += $P[$v1_index]; $N++; }

		if ($P[$v1_index] eq 'U') { next; }

      if ($pattern =~ /\*/) {
         if ($P[$txt_index]=~ /$pattern/i) {$result += $P[$v1_index]; $N++;}
      }
      else {
         if ((uc $P[$txt_index] eq uc $pattern) || $pattern eq '.*') {$result += $P[$v1_index]; $N++; }
      }
   }

	if ($N==0) { $result='U'; }
	else { $result /= $N; }
   return [$result];

}




#----------------------------------------------------------------------------
# Funcion: esp_fx_sum
# Descripcion:
#
#  Sobre los valores devueltos por el walk de una tabla subre un campo.
#  Hace una comprobacion de patrones y devuelve la suma del valor asociado
#  al patron que se esta comprobando.
#  P.ej: Sumar la memoria/cpu de un determinado proocesos llamado xxx ($param).
#
#  mod_snmp_walk:sum(svchost\.exe)
#
# IN:
#     $desc:      Vector de datos de configuracion
#     $task_id:   ID de Tarea. module_name + ip
#     $values:    Resultado del walk
# OUT:
#     Devuelve el resultado ($result)
#----------------------------------------------------------------------------
sub esp_fx_sum  {
my ($self,$task_id,$desc,$param,$iparam,$values)=@_;

	$MITEMS=1;
   my $result=0;
   if ((! $param) || ($param eq '*')) {
		$result = scalar @$values;
		return [$result];
	}

   #------------------------------------------------------
   #Parsing de $iparam p.ej: txt=1;v1=2 (porque iid=0)
   my @i=split(';',$iparam);
   my %ipar=();
   foreach my $x (@i) {
      my ($k,$v)=split('=',$x);
      $ipar{$k}=$v;
   }
   my $txt_index=$ipar{'txt'};
   my $v1_index=$ipar{'v1'};

   #------------------------------------------------------
   my $pattern=$param;
   $pattern =~ s/\\//g;
   $pattern =~ s/\*/\.\*\?/g;

   foreach my $l (@$values) {
      ## OJO El primer valor es el iid !!
      #my ($id,$v1,$v2)=split(':@:',$l);
      #if ($v1=~ /$pattern/i) {$result += $v2; }

      # El indice del pattern viene dado por el $ipar{'txt'}
      my @P=split(':@:',$l);

      $P[$txt_index] =~ s/^"(.+)"$/$1/g;
      $P[$txt_index] =~ s/^'(.+)'$/$1/g;

   #$self->log('debug',"esp_fx_sum::[DEBUG ID=$task_id] pattern=$pattern P=$P[$txt_index]**");

      #if ($P[$txt_index]=~ /$pattern/i) {$result += $P[$v1_index]; }
		#if ((uc $P[$txt_index] eq uc $pattern) || $pattern eq '.*') { $result += $P[$v1_index]; }

		if ($P[$v1_index] eq 'U') { next; }

      if ($pattern =~ /\*/) {
         if ($P[$txt_index]=~ /$pattern/i) {$result += $P[$v1_index]; }
      }
      else {
         if ((uc $P[$txt_index] eq uc $pattern) || $pattern eq '.*') {$result += $P[$v1_index]; }
      }

   }
   return [$result];

}



#----------------------------------------------------------------------------
# Funcion: esp_fx_subkey
# Descripcion:
#	Los valores devueltos por el walk son el mapeo de un texto --> ID
#	Obtiene el ID asociado al texto pasado como parametro. Con dicho ID
#	recorre otra tabla proporcionando los valores solicitados
#
#	mod_snmp_walk:subkey(maquina1,VMWARE-RESOURCES-MIB::cpuUtil)
#	mod_snmp_walk:subkey(maquina1,VMWARE-RESOURCES-MIB::memConfigured_VMWARE-RESOURCES-MIB::memUtil)
#
# IN:
#     $desc:      Vector de datos de configuracion
#     $task_id:   ID de Tarea. module_name + ip
#     $values:    Resultado del walk
# OUT:
#     Devuelve el resultado ($result)
#----------------------------------------------------------------------------
sub esp_fx_subkey  {
my ($self,$task_id,$desc,$param,$iparam,$values)=@_;


	my @p=split(';',$param);
	my $pattern=$p[0];
	my $oid_new=$p[1];
	my @o=split('_',$oid_new);
	my $nitems=scalar @o;
   my @res=();
	my $result=undef;

	# AQUI el resultado depende del numero de items !!!!!
   if ((! $pattern) || ($pattern eq '*') || (! $oid_new) ) {
		for (my $i=0;$i<$nitems;$i++) { push (@res,'U'); }
		#$result=join(':',@res);
		#return  $result;
		return \@res;
	}

	my $id_new=undef;
   foreach my $l (@$values) {

		#4:@:4:@:224:@:"Mu"
      my ($id0,$id,$idx,$name)=split(':@:',$l);
      #my ($idx,$name)=split(':@:',$l);
      if ($name=~ /$pattern/i) { $id_new=$idx;  last; }
   }


#DBG--
   $self->log('debug',"esp_fx_subkey::[DEBUG ID=$task_id] pattern=$pattern  id_new=$id_new**");
#/DBG--

   # Revisar retorno + logs
   if (!defined $id_new ) { return  [0]; }

	$desc->{oid}=$oid_new;
	my $newvalues=$self->core_snmp_table($desc);


#DBG--
$self->log('debug',"esp_fx_subkey::[DEBUG ID=$task_id] RES DEL WALK=@$newvalues**");
#/DBG--

   foreach my $l (@$newvalues) {

      my @d=split(':@:',$l);
      if ($d[0]=~ /$id_new/i) {
	      for (my $i=1;$i<=$nitems;$i++) { push (@res,$d[$i]); }
		}
   }


#	$desc->{oid}='cpuUtil.'.$id_new;
#   my $r=$self->core_snmp_get($desc);
#   my $rc=$self->err_num();
#   if ($rc == 0) {  return $r->[0];  }

#DBG--
$self->log('debug',"esp_fx_subkey::[DEBUG ID=$task_id] RESULT =@res**");
#/DBG--

#	$result=join(':',@res);
	$MITEMS=scalar @res;
   return \@res;

}


#----------------------------------------------------------------------------
# Funcion: esp_fx_ordinal_iid
# Descripcion:
#
#  Sobre los valores devueltos por el walk hace dos cosas:
#		1. Lor considera ordinalmente (primero,segundo,tercero ....) al margen
#		del valor numerico real que tengan. P. ej: Si los iids son el
#		1,5,888,900 los considera como primero,segundo, tercero y cuarto.
#		Si en un mamento dado, esos iids se modifican y se convierten en:
#		100,101,400,405 el 100 ocupa alimenta los datos del primero, el 101 del
#		segundo y asi sucesivamente.
#		2. Por otra parte, sumariza todos los iids en una unica grafica.
#
#	IMPORTANTE: Esta es una metrica especial que no tiene parametros de usuario
#	por lo que puede estar directamente en el repositorio, ya que no es necesario
#	que el usuario la instancie.
#  mod_snmp_walk:esp_fx_ordinal_iid()(v1=1)
#
# IN:
#     $desc:      Vector de datos de configuracion
#     $param:   	Parametros aignados por el usuario.
#     $iparam:   	Parametros internos de la metrica.
#						v1=indice. Indica la posicion de la columna a considerar
#     $values:    Resultado del walk
# OUT:
#     Devuelve el resultado (@result)
#----------------------------------------------------------------------------
sub esp_fx_ordinal_iid  {
my ($self,$task_id,$desc,$param,$iparam,$values)=@_;


   #------------------------------------------------------
   #Parsing de $iparam p.ej: v1=1 (porque iid=0)
   my @i=split(';',$iparam);
   my %ipar=();
   foreach my $x (@i) {
      my ($k,$v)=split('=',$x);
      $ipar{$k}=$v;
   }
   my $v1_index=$ipar{'v1'};

   my @result=();
   foreach my $l (@$values) {
      ## OJO El primer valor es el iid !!
#1:@:22
#2:@:2
#3:@:52
#4:@:1

      # El indice del valor a considerar viene dado por el $ipar{'v1'}
      my @P=split(':@:',$l);
		push @result, $P[$v1_index];
   }

	$MITEMS=scalar @result;
   return \@result;
}


##----------------------------------------------------------------------------
## do_esp_fx
##
## Ejecuta las funciones especificadas en esp (fx)
##----------------------------------------------------------------------------
#sub do_esp_fx  {
#my ($self,$desc,$values)=@_;
#
#
#	# Si no existe esp_fx asociada a la metrica termina
#   my $fx=$desc->{'esp'};
#   if ($fx eq '') { return $values; }
#
#	# En caso contrario se procesa esp_fx
#	my @newvals=();
#	my $subtype=$desc->{'subtype'};
#	my @esp=split(/\|/,$desc->{'esp'});
#	my $nitems=scalar(@esp);
#
#$self->log('debug',"do_esp_fx:: *****START**** subtype=$subtype values=@$values esp=@esp");
#
#   # Si los valores son U, se responde U
#   my $nv=scalar(@$values);
#   my $x=0;
#   foreach my $v (@$values) {
#      if ($v eq 'U') { $x+=1; }
#   }
#	if ($x==$nv) { 
#      for my $i (0..$nitems-1) { push @newvals, 'U'; }
#      return \@newvals;
#	}
#
#	eval {
#
#		for my $i (0..$nitems-1) {
#			if ($esp[$i] eq '') { 
#				push @newvals, $values->[$i]; 
#				next; 
#			}
#
#$self->log('debug',"do_esp_fx:: subtype=$subtype (I=$i) PROCESANDO --$esp[$i]--");
#
#			# ------------------------------------------------
#			# Evaluamos $esp[$i]
#			# ------------------------------------------------
#			my $esp_base=$esp[$i];
#			$esp_base =~ s/map\(/MAP\(/g;
#			$esp_base =~ s/int\(/INT\(/g;
#			$esp_base =~ s/csv\(/CSV\(/g;
#
#			# ------------------------------------------------
#			# 1. Funcion MAP()()
#			# ------------------------------------------------
#			# Caso numerico
#			if ($esp_base =~ /MAP\(([\d+|\,]+)\)\(([\d+|\,]+)\)/) {	
#				my ($a,$b)=($1,$2);
#				my @vx=split(',',$a); 		
#				my @rx=split(',',$b); 		
#				my $nv=scalar(@vx);
#				# Se inicializa a algun valor @newvals para el caso en el que 
#				# no cumplaninguna condicion
#				my $nr=scalar(@rx);
#				@newvals=();
#				for my $i (0..$nr-1) { push @newvals,0; }	
#				# Miramos si los valores de $values cumplen la condicion ...
#				my $ok=0;
#				for my $i (0..$nv-1) {
#					if (($vx[$i]==$values->[$i]) || ($vx[$i] eq '*') ) { $ok+=1; }
#				}
#				if ($ok == $nv) { 
#					@newvals=@rx;
#					last;
#				}
#				# En este caso no se procesan mas funciones
#				next;
#			}
#			# Caso texto
#         elsif ($esp_base =~ /MAP\((.+)\)\(([\d+|\,]+)\)/) {
#            my ($a,$b)=($1,$2);
#            my @vx=split(',',$a);
#            my @rx=split(',',$b);
#            my $nv=scalar(@vx);
#            # Se inicializa a algun valor @newvals para el caso en el que
#            # no cumplaninguna condicion
#            my $nr=scalar(@rx);
#            @newvals=();
#            for my $i (0..$nr-1) { push @newvals,0; }
#            # Miramos si los valores de $values cumplen la condicion ...
#            my $ok=0;
#            for my $i (0..$nv-1) {
#               if (($vx[$i]  =~ /$values->[$i]/) || ($vx[$i] eq '*') ) { $ok+=1; }
#            }
#            if ($ok == $nv) {
#               @newvals=@rx;
#               last;
#            }
#            # En este caso no se procesan mas funciones
#            next;
#         }
#
#			# ------------------------------------------------
#			# 2. Funciones atomicas: INT(vx)
#			# ------------------------------------------------
#			my %intermediate=();
#			while ($esp_base =~ /INT\(o(\d+)\)/g) {
#				my $aux=$1;
#				my $v=$values->[$aux-1];
#				$v=~ s/,/\./g;
#				$intermediate{"INT\\(o$aux\\)"} = $self->fx_INT($v);	
#
#$self->log('debug',"do_esp_fx:: subtype=$subtype (I=$i) EN BUCLE fx=INT()");
#			}
#
#my @kk=keys %intermediate;
#$self->log('debug',"do_esp_fx:: subtype=$subtype (I=$i) MIRO KEYS kk=@kk");
#
#         foreach my $expr (keys %intermediate) {
#            my $result=$intermediate{$expr};
#         $self->log('debug',"do_esp_fx:: subtype=$subtype HAGO SUBST DE $esp_base >> / $expr / $result /");
#
#            $esp_base =~ s/$expr/$result/;
#         }
#
#			# ------------------------------------------------
#			# 2. Funciones atomicas: CSV()
#			# ------------------------------------------------
#			%intermediate=();
#         while ($esp_base =~ /(CSV\(.*?\))/g) {
#				my $fx=$1;
#				if ($fx=~ /CSV\(o(\d+)\,\"+([\,|\;|\s+])\"+\,(\d+)\)/) {
#	            my ($aux,$sep,$pos)=($1,$2,$3);
#         	   my $v=$values->[$aux-1];
#            	$intermediate{"CSV\\(o$aux,\"$sep\",$pos\\)"} = $self->fx_CSV($v, {'separator'=>$sep, 'position'=>$pos});
#
#$self->log('debug',"do_esp_fx:: subtype=$subtype (I=$i) EN BUCLE fx=CSV() aux=$aux sep=$sep pos=$pos");
#				}
#            elsif ($fx=~ /CSV\(o(\d+)\,\'+([\,|\;|\s+])\'+\,(\d+)\)/) {
#               my ($aux,$sep,$pos)=($1,$2,$3);
#               my $v=$values->[$aux-1];
#               $intermediate{"CSV\\(o$aux,\'$sep\',$pos\\)"} = $self->fx_CSV($v, {'separator'=>$sep, 'position'=>$pos});
#
#$self->log('debug',"do_esp_fx:: subtype=$subtype (I=$i) EN BUCLE fx=CSV() aux=$aux sep=$sep pos=$pos");
#            }
#
#         }
#
#@kk=keys %intermediate;
#$self->log('debug',"do_esp_fx:: subtype=$subtype (I=$i) MIRO KEYS kk=@kk");
#
#			foreach my $expr (keys %intermediate) {
#				my $result=$intermediate{$expr};
#			$self->log('warning',"do_esp_fx:: subtype=$subtype HAGO SUBST DE $esp_base >> / $expr / $result /");
#
#				$esp_base =~ s/$expr/$result/;
#			}
#
#$self->log('debug',"do_esp_fx:: subtype=$subtype (I=$i) MIRO esp_base=$esp_base");
#
#
#         # ------------------------------------------------
#         # 2. Funciones atomicas: IF(cond,vok,vnok)
#         # ------------------------------------------------
#         %intermediate=();
#         while ($esp_base =~ /IF\((.*?),(.*?),(.*?)\)/g) {
#            my ($cond,$vok,$vnok)=($1,$2,$3);
#            #my $v=$values->[$aux-1];
#            $intermediate{"IF\\($cond,$vok,$vnok\\)"} = $self->fx_IF($values, {'condition'=>$cond, 'vok'=>$vok, 'vnok'=>$vnok});
#
#$self->log('debug',"do_esp_fx:: subtype=$subtype (I=$i) EN BUCLE fx=IF( condition=$cond vok=$vok vnok=$vnok) ");
#			}
#
#
#			# ------------------------------------------------
#		   # 3. Se substituye vx por cada valor
#			# ------------------------------------------------
#		   for my $i (1..10) {
#      		my $j=$i-1;
#      		if ($esp_base =~ /o$i/i) {
#         		$esp_base =~ s/o$i/$values->[$j]/ig;
#$self->log('debug',"do_esp_fx:: subtype=$subtype esp_base=$esp_base SUBST o$i");
#      		}
#   		}
#
##		   #----------------------------------------------------
##   		#Sustituyo = por ==
##   		while ($esp_base =~ s/([^=]+)=([^=|^~]+)/$1==$2/g) {}
##   		#Sustituyo <> por !=
##   		while ($esp_base =~ s/<>/!=/g) {}
##   		#Sustituyo (0/0) por (0)
##   		while ($esp_base =~ s/\(0\/0\)/\(0\)/g) {}
##   		#Sustituyo (0/0) por (0)
## 		 	$esp_base =~ s/^(.*?)(\s*[=|!]+~.*)$/'$1'$2/;
#
#			# ------------------------------------------------
#			# Operaciones aritmeticas +,-,*,/,%
#        	# Para hacer el eval 'untainted'
#         if ($esp_base =~ /(.+)/) { $esp_base = eval $1; }
#
#
#			# ------------------------------------------------
#			if ($esp_base =~ /^[\d+|\.]+$/) {
#				$self->log('debug',"do_esp_fx:: subtype=$subtype PROCESADO OK $esp[$i] RES=$esp_base");
#         	push @newvals, $esp_base;
#         	next;
#      	}
#
#			$self->log('debug',"do_esp_fx:: subtype=$subtype NO SE HA PROCESADO $esp[$i] RES=$esp_base");
#		}	
#	};
#	if ($@) {  
#		$self->log('warning',"do_esp_fx:: **ERROR EN EVAL** ($@)"); 
#	} 
#
#	return \@newvals;
#}
#
#
##----------------------------------------------------------------------------
## fx_INT
## INT(v1)	>>		$snmp->fx_INT($v1);
##
## IN: $value es un escalar con el valor 		->  "3 mv"
## OUT: $newvalue es un escalar con el valor	->	3
##----------------------------------------------------------------------------
#sub fx_INT   {
#my ($self,$value)=@_;
#
#	my $newvalue=$value;
#	if ($value=~/^\s*.*?([\d+|\.+|\,+]+).*?$/) {
#  		$newvalue=$1;
#  		if( $newvalue =~/\.$/) {$newvalue.='0'; }
#	}
#	return $newvalue;
#}
#
##----------------------------------------------------------------------------
## fx_CSV
## CSV(v1,',',0) 	>>	$snmp->fx_CSV($v1,{'separator'=>',', 'position'=>0})
##
## IN: $value es un escalar con el valor						-> "1,2,3"
## OUT: $newvalue es una ref a un array con los valores  	-> [ 1, 2, 3]
##----------------------------------------------------------------------------
#sub fx_CSV   {
#my ($self,$value,$params)=@_;
#
#	my ($separator, $position)=(',',1);
#	if (exists $params->{'separator'}) {$separator=$params->{'separator'}; }
#	if (exists $params->{'position'}) {$position=$params->{'position'}; }
#	if ($position<1) { $position=1; }
#
#	if ($separator eq '') { $separator='\s+'; }
#   #my @newvalues=();
#   $value=~s/"//g;
#   $value=~s/'//g;
#	my @d=split(/$separator/,$value);
#	#push @newvalues, $d[$position];
#   #return \@newvalues;
#	
#	return $d[$position-1];
#}
#
#
##----------------------------------------------------------------------------
## fx_IF
## IF(cond,vok,vnok)	
## IF(o1>2),o1,o2)		>>	$snmp->fx_IF($v1,{'condition'=>'o1>2', 'vok'=>'o1', 'vnok'=>'o2')
##
## IN: $value es un escalar con el valor                  -> "1,2,3"
## OUT: $newvalue es una ref a un array con los valores   -> [ 1, 2, 3]
##----------------------------------------------------------------------------
#sub fx_IF   {
#my ($self,$value,$params)=@_;
#
#   my ($condition,$vok,$vnok)=('','','');
#   if (exists $params->{'condition'}) {$condition=$params->{'condition'}; }
#   if (exists $params->{'vok'}) {$vok=$params->{'vok'}; }
#   if (exists $params->{'vnok'}) {$vnok=$params->{'vnok'}; }
#
#	my $r = eval $condition;
#	my $result = ($r) ? $vok : $vnok;
#
#   return $result;
#}
#
##----------------------------------------------------------------------------
## fx_MAP
## MAP(0+0=0,0+1=1,1+0=2,))   >> $snmp->fx_CSV($v1,{'separator'=>',', 'position'=>0})
##
## Mapea de N a M valores
## v1 v2	=> r1 r2 r3 r4
## 0  0		0  0  0  1
## 0  1		0  0  1  0
## 1  0		0  1  0  0
## 1  1		1  0  0  0
##
## if ((v1==0) && (v2==0)) { [0 0 0 1] }	MAP(0,0)(0,0,0,1)
## IN: $value es una ref a un array con los valores de entrada     -> [ 1, 0]
## OUT: $newvalue es una ref a un array con los valores de salida	-> [ 0, 0, 0, 1]
##----------------------------------------------------------------------------
#sub fx_MAP   {
#my ($self,$value,$params)=@_;
#
#
#
#}
#

1;
__END__

