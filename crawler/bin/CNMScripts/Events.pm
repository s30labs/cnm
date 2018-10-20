#-------------------------------------------------------------------------------------------
# Fichero: CNMScripts/Events.pm
# Descripcion:
#-------------------------------------------------------------------------------------------
use CNMScripts;
package CNMScripts::Events;
@ISA=qw(CNMScripts);

use lib '/opt/crawler/bin';
use strict;
use Crawler;
use Data::Dumper;
use JSON;

my $VERSION = '1.00';

#-------------------------------------------------------------------------------------------
# Funcion: Constructor
# Descripcion: Crea un objeto del tipo CNMScripts::StoreConfig
#-------------------------------------------------------------------------------------------
sub new {
my ($class,%arg) =@_;

   my $self=$class->SUPER::new(%arg);
   #$self->{_store_limit} = $arg{store_limit} || 10;

   return $self;
}

#----------------------------------------------------------------------------
# get_application_events
# Returns ($event_counter,$event_info,$last_ts)
# a. 	$event_counter -> Numero de filas que cumplen el patron $params->{'pattern'} 
#		durante la ventana now-$params->{'lapse'}
# b. 	$event_info -> Devuelve el valor de la linea mas reciente que cumple el patron 
#		$params->{'pattern'} durante la ventana now-$params->{'lapse'}
# c.	$last_ts -> Ultimo valor de ts (date) almacenado que cumple el patron
#		$params->{'pattern'} durante la ventana now-$params->{'lapse'}
#----------------------------------------------------------------------------
sub get_application_events {
my ($self,$dbh,$params)=@_;

	
   my $id_app = $params->{'id_app'};
   my $lapse = $params->{'lapse'} || 60;
	$lapse *= 60;
	my $pattern = $params->{'pattern'} || '';
	$self->err_str('OK');
	$self->err_num(0);


	my ($event_counter,$event_info,$last_ts) = ('U','UNK','U');
   my $res = $self->dbCmd($dbh,"SELECT tabname FROM device2log WHERE tabname LIKE '%$id_app%'");
   if ($res->[0] !~ /log/) {
		$event_info = "**ERROR** NO EXISTE TABLA PARA ID APP $id_app";
		$self->err_str($event_info);
		$self->err_num(1);
   	return ($event_counter,$event_info);
	}

   my $tabname = $res->[0];

   my $SQL="SELECT count(*) FROM __TABLE__ WHERE line like '%__PATTERN__%' AND ts>unix_timestamp(now())-__LAPSE__";
   $SQL =~ s/__TABLE__/$tabname/;
   $SQL =~ s/__PATTERN__/$pattern/;
   $SQL =~ s/__LAPSE__/$lapse/;

	$self->log('debug',"**DEBUG** dbCmd >> $SQL");

   $res = $self->dbCmd($dbh,$SQL);
	if ($self->err_num() == 0) { $event_counter = $res->[0]; }
	else {
		$self->log('warning',"ERROR dbCmd >> $SQL");
		$event_info = $self->err_str();
   	return ($event_counter,$event_info);
	}


	$SQL="SELECT substr(line,1,5000) FROM __TABLE__ WHERE line like '%__PATTERN__%' AND ts>unix_timestamp(now())-__LAPSE__ ORDER BY id_log desc LIMIT 1";
   $SQL =~ s/__TABLE__/$tabname/;
   $SQL =~ s/__PATTERN__/$pattern/;
   $SQL =~ s/__LAPSE__/$lapse/;

	$self->log('debug',"**DEBUG** dbCmd >> $SQL");

   $res = $self->dbCmd($dbh,$SQL);
   if ($self->err_num() == 0) { $event_info = $res->[0]; }
   else {
      $self->log('warning',"ERROR dbCmd >> $SQL");
      $event_info = '';
      return ($event_counter,$event_info);
   }

   $SQL="SELECT ts FROM __TABLE__ ORDER BY id_log DESC LIMIT 1";
   $SQL =~ s/__TABLE__/$tabname/;

   $self->log('debug',"**DEBUG** dbCmd >> $SQL");

   $res = $self->dbCmd($dbh,$SQL);
   if ($self->err_num() == 0) { $last_ts = $res->[0]; }
   else {
      $self->log('warning',"ERROR dbCmd >> $SQL");
   }

	$self->log('debug',"**DEBUG** RES >> $event_counter | $event_info | $last_ts");

   return ($event_counter,$event_info,$last_ts);
}


#----------------------------------------------------------------------------
# get_application_events_json
# Returns ($event_counter,$event_info,$last_ts)
# a.  $event_counter -> Numero de filas que cumplen el patron $params->{'pattern'}
#     durante la ventana now-$params->{'lapse'}
# b.  $event_info -> Devuelve el valor de la linea mas reciente que cumple el patron
#     $params->{'pattern'} durante la ventana now-$params->{'lapse'}
# c.  $last_ts -> Ultimo valor de ts (date) almacenado que cumple el patron
#     $params->{'pattern'} durante la ventana now-$params->{'lapse'}
#----------------------------------------------------------------------------
sub get_application_events_json {
my ($self,$dbh,$params)=@_;


   my $id_app = $params->{'id_app'};
   my $lapse = $params->{'lapse'} || 60;
   $lapse *= 60;
   my $pattern = $params->{'pattern'} || '';
   $self->err_str('OK');
   $self->err_num(0);


   my ($event_counter,$event_info,$last_ts) = ('U','UNK','U');

	# Se obtiene el nombre de la tabla a partir del id. 
	# 333333001009 -> logp_333333001009_icgTPVSessions_from_db
   my $res = $self->dbCmd($dbh,"SELECT tabname FROM device2log WHERE tabname LIKE '%$id_app%'");
   if ($res->[0] !~ /log/) {
      $event_info = "**ERROR** NO EXISTE TABLA PARA ID APP $id_app";
      $self->err_str($event_info);
      $self->err_num(1);
      return ($event_counter,$event_info);
   }

   my $tabname = $res->[0];

	#EJ: my $SQL="SELECT id_log,hash,ts,line FROM logp_333333001009_icgTPVSessions_from_db WHERE ts>unix_timestamp(now())-3600;";
	my $SQL="SELECT id_log,hash,ts,line FROM __TABLE__ WHERE ts>unix_timestamp(now())-__LAPSE__ ORDER BY id_log desc;";
   $SQL =~ s/__TABLE__/$tabname/;
   $SQL =~ s/__LAPSE__/$lapse/;

   $self->log('debug',"**DEBUG** dbCmd >> $SQL");

   $res = $self->dbSelectAll($dbh,$SQL);
   if ($self->err_num() != 0) { 
      $self->log('warning',"ERROR dbCmd >> $SQL");
      $event_info = $self->err_str();
      return ($event_counter,$event_info);
   }

	# pattern puede ser una lista de condiciones separadas por _AND_ o _OR_
	# EJ: clase|eq|Q2_AND_TRANSCOLA|gt|10
	# Cada condicion es del tipo: TRANSCOLA|gt|10 o ERRORMSG|eq|"" -> key|operador|value
	# Los operadores soportados son: gt, gte, lt, lte, eq, ne
	$event_counter = 0;

	my @pattern_line = ($pattern);
	my $pattern_type = 'AND';
	if ($pattern =~ /_AND_/) {
		@pattern_line = split (/_AND_/,$pattern);
	}
	elsif ($pattern =~ /_OR_/) {
      @pattern_line = split (/_OR_/,$pattern);
		$pattern_type = 'OR';
   }

	my %patterns = ();
	foreach my $p (@pattern_line) {
		my ($k,$op,$value) = split(/\|/,$p);
		my $kuc = uc $k;
		$patterns{$kuc} = { 'k'=>$k, 'op'=>$op, 'value'=>$value };
#$self->log('info',"**DEBUG** CLAVE $kuc >> k=$k op=$op value=$value");
	}

	my $npatterns = scalar(keys %patterns);

	foreach my $l (@$res) {

		my $data = $self->json2h($l->[3]);

		$self->log('info',"**DEBUG** RES $l->[3]");
		my $ok = 0;
		foreach my $k (keys %$data) {
			my $kx = uc $k;

#$self->log('info',"**DEBUG** CLAVE $kx - pattern=$pattern");

			if (! exists $patterns{$kx}) { next; }
			my $op = $patterns{$kx}->{'op'};
			my $value = $patterns{$kx}->{'value'};
#$self->log('info',"**DEBUG** op=$op value=$value");

			#Operandos: ne, gt, lt, gte, lte
			if (($op =~ /gte/i) && ($data->{$k} >= $value)) { $ok += 1; }
			elsif (($op =~ /gt/i) && ($data->{$k} > $value)) { $ok += 1; }
			elsif (($op =~ /lte/i) && ($data->{$k} <= $value)) { $ok += 1; }
			elsif (($op =~ /lt/i) && ($data->{$k} < $value)) { $ok += 1; }
			elsif ($op =~ /ne/i) {
				if (($data->{$k}=~/^\d+(?:\.\d+)?$/) && ($data->{$k} != $value)) { $ok += 1; }
				elsif ($data->{$k} ne $value) { $ok += 1; }
			}
			elsif ($op =~ /eq/i) {
            if (($data->{$k}=~/^\d+(?:\.\d+)?$/) && ($data->{$k} == $value)) { $ok += 1; }
            elsif ($data->{$k} eq $value) { $ok += 1; }
			}

			$self->log('info',"**DEBUG** CHECK $data->{$k} $op $value -> ok=$ok");
		}

		if (($pattern_type eq 'AND') && ($ok == $npatterns)) { $event_counter += 1; }
		elsif (($pattern_type eq 'OR') && ($ok>0)) { $event_counter += 1; }

		if ($event_counter == 1) {
			$event_info = $l->[3];
			$last_ts = $l->[2];
		}
	}
   return ($event_counter,$event_info,$last_ts);
}

#----------------------------------------------------------------------------
# get_last_status_event
#----------------------------------------------------------------------------
# Obtiene el ultimo evento de estado almacenado (en base a pattern)
# e identifica de que tipo es (en base a $status_map)
# Devuelve el estado -> Hash con todos los estados 
#----------------------------------------------------------------------------
sub get_last_status_event {
my ($self,$dbh,$params,$status_map)=@_;

#$status_map = [
#	{'name'=>'JOB Started', 'pattern'=>'"Subject":"ASAPRO - JOB Started : application TJBWESSALESMETAC"'},
#	{'name'=>'JOB Ended', 'pattern'=>'"Subject":"ASAPRO - JOB Ended : application TJBWESSALESMETAC"'}
#]
   my $id_app = $params->{'id_app'};
   my $pattern = $params->{'pattern'} || '';
   $self->err_str('OK');
   $self->err_num(0);

   my ($status,$event_info,$last_ts) = ('U','UNK','U');
   my $res = $self->dbCmd($dbh,"SELECT tabname FROM device2log WHERE tabname LIKE '%$id_app%'");
   if ($res->[0] !~ /log/) {
      $event_info = "**ERROR** NO EXISTE TABLA PARA ID APP $id_app";
      $self->err_str($event_info);
      $self->err_num(1);
      return ($status,$event_info);
   }

   my $tabname = $res->[0];

   my $SQL="SELECT substr(line,1,5000),ts FROM __TABLE__ WHERE line like '%__PATTERN__%' ORDER BY id_log desc LIMIT 1";
   $SQL =~ s/__TABLE__/$tabname/;
   $SQL =~ s/__PATTERN__/$pattern/;

   $self->log('debug',"**DEBUG** dbCmd >> $SQL");

   $res = $self->dbCmd($dbh,$SQL);
   if ($self->err_num() == 0) { $event_info = $res->[0]; }
   else {
      $self->log('warning',"ERROR dbCmd >> $SQL");
      $event_info = '';
      return ($status,$event_info);
   }

	my $last_stored = $res->[0];
	$last_ts = $res->[1];	

	foreach my $l (@$status_map) {
		my $pat = $l->{'pattern'};
		if ($last_stored =~ /$pat/) { 
			$status = $l->{'value'}; 
			last;
		}
	}

	return ($status,$event_info,$last_ts);
}


#----------------------------------------------------------------------------
# get_application_data
# Returns ($data_value,$event_info,$last_ts)
# a.  $data_value -> Valor del dato solicitado Contenido el campo field de las 
#		filas que cumplen el patron $params->{'pattern'} durante la ventana 
#		de tiempo now-$params->{'lapse'}
# b.  $event_info -> Devuelve el valor de la linea mas reciente que cumple el patron
#     $params->{'pattern'} durante la ventana now-$params->{'lapse'}
# c.  $last_ts -> Ultimo valor de ts (date) almacenado que cumple el patron
#     $params->{'pattern'} durante la ventana now-$params->{'lapse'}
#----------------------------------------------------------------------------
sub get_application_data {
my ($self,$dbh,$params)=@_;


   my $id_app = $params->{'id_app'};
   my $field = $params->{'field'};
   my $lapse = $params->{'lapse'} || 60;
   $lapse *= 60;
   my $pattern = $params->{'pattern'} || '';
   $self->err_str('OK');
   $self->err_num(0);


   my ($data_value,$event_info,$last_ts) = ('U','UNK','U');

   # Se obtiene el nombre de la tabla a partir del id.
   # 333333001009 -> logp_333333001009_icgTPVSessions_from_db
   my $res = $self->dbCmd($dbh,"SELECT tabname FROM device2log WHERE tabname LIKE '%$id_app%'");
   if ($res->[0] !~ /log/) {
      $event_info = "**ERROR** NO EXISTE TABLA PARA ID APP $id_app";
      $self->err_str($event_info);
      $self->err_num(1);
      return ($data_value,$event_info);
   }

   my $tabname = $res->[0];

   #EJ: my $SQL="SELECT id_log,hash,ts,line FROM logp_333333001009_icgTPVSessions_from_db WHERE ts>unix_timestamp(now())-3600;";
   my $SQL="SELECT id_log,hash,ts,line FROM __TABLE__ WHERE ts>unix_timestamp(now())-__LAPSE__ ORDER BY id_log desc;";
   $SQL =~ s/__TABLE__/$tabname/;
   $SQL =~ s/__LAPSE__/$lapse/;

   $self->log('debug',"**DEBUG** dbCmd >> $SQL");

   $res = $self->dbSelectAll($dbh,$SQL);
   if ($self->err_num() != 0) {
      $self->log('warning',"ERROR dbCmd >> $SQL");
      $event_info = $self->err_str();
      return ($data_value,$event_info);
   }

	$data_value = 0;

   foreach my $l (@$res) {

      my $data = $self->json2h($l->[3]);

		if (! exists $data->{$field}) {next;}
		$data_value = $data->{$field};
      $event_info = $l->[3];
      $last_ts = $l->[2];
      $self->log('info',"**DEBUG** RES data_value=$data_value");
	}

   return ($data_value,$event_info,$last_ts);
}




#----------------------------------------------------------------------------
sub json2h {
my ($self,$line)=@_;

   my $data = {};
   eval {
      $data = decode_json($line);
   };
   if ($@) {
		$self->log('warning',"ERROR EN JSON ($@) >> $line");
   }

	return $data;
}



1;
__END__


