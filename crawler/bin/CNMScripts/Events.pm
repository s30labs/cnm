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


#	#WAIT if lock
#	my $fl = '/var/run/'.$id_app.'.lock';
#	my $n=15;	#15 seg.
#	while ($n>0) {
#		$n--;
#		if (-f $fl) { 
#			$self->log('debug',"**WAITING FOR LOCK**");
#			sleep 1; 
#		}
#		else { last; }
#	}

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

	# $event_info ocupa mucho
	#$self->log('debug',"**DEBUG** RES >> $event_counter | $event_info | $last_ts");
	$self->log('debug',"**DEBUG** RES >> $event_counter | pattern=$pattern | $last_ts");

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
		if (! exists $patterns{$kuc}) {
			$patterns{$kuc} = [ { 'k'=>$k, 'op'=>$op, 'value'=>$value } ]; 
		}
		else { push @{$patterns{$kuc}}, { 'k'=>$k, 'op'=>$op, 'value'=>$value }; }

#$self->log('info',"**DEBUG** CLAVE $kuc >> k=$k op=$op value=$value");
	}

	my $npatterns = scalar(keys %patterns);

	foreach my $l (@$res) {

		my $data = $self->json2h($l->[3]);

		#$self->log('info',"**DEBUG** RES $l->[3]");
		my $ok = 0;
		foreach my $k (keys %$data) {
			my $kx = uc $k;

			if (! exists $patterns{$kx}) { next; }
#$self->log('info',"**DEBUG** CHECK-CLAVE $kx - pattern=$pattern");

			foreach my $h (@{$patterns{$kx}})  {

				#my $op = $patterns{$kx}->{'op'};
				#my $value = $patterns{$kx}->{'value'};

            my $op = $h->{'op'};
            my $value = $h->{'value'};

				#Operandos: eqs, match, ne, gt, lt, gte, lte
				if (($op =~ /eqs/i) && ($data->{$k} eq $value)) { $ok += 1; }
				elsif (($op =~ /match/i) && ($data->{$k} =~/$value/)) { $ok += 1; }
				elsif (($op =~ /gte/i) && ($data->{$k} >= $value)) { $ok += 1; }
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

				#$self->log('info',"**DEBUG** CHECK ($kx) --$data->{$k}--$op--$value-- -> ok=$ok");
			}
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
#		Devuelve el valor de la primera fila encontrada !!!
# b.  $event_info -> Devuelve el valor de la linea mas reciente que cumple el patron
#     $params->{'pattern'} durante la ventana now-$params->{'lapse'}
# c.  $last_ts -> Ultimo valor de ts (date) almacenado que cumple el patron
#     $params->{'pattern'} durante la ventana now-$params->{'lapse'}
#----------------------------------------------------------------------------
sub get_application_data {
my ($self,$dbh,$params)=@_;


   my $id_app = $params->{'id_app'};
   # my $field = $params->{'field'};
	# Se pueden especificar varios campos separados por "|"
	my @fields = split(/\|/, $params->{'field'});
	my $num_fields = scalar(@fields);

   my $lapse = $params->{'lapse'} || 60;
   $lapse *= 60;
   my $pattern = $params->{'pattern'} || '';


	my $pat = $self->prepare_patterns($pattern);
	


   $self->err_str('OK');
   $self->err_num(0);

   my %data_value=();
   foreach my $f (@fields) { $data_value{$f} = 'U'; }
   my ($event_info,$last_ts) = ('UNK','U');

   # Se obtiene el nombre de la tabla a partir del id.
   # 333333001009 -> logp_333333001009_icgTPVSessions_from_db
   my $res = $self->dbCmd($dbh,"SELECT tabname FROM device2log WHERE tabname LIKE '%$id_app%'");
   if ($res->[0] !~ /log/) {
      $event_info = "**ERROR** NO EXISTE TABLA PARA ID APP $id_app";
      $self->err_str($event_info);
      $self->err_num(1);
      return (\%data_value,$event_info);
   }

   my $tabname = $res->[0];

   #EJ: my $SQL="SELECT id_log,hash,ts,line FROM logp_333333001009_icgTPVSessions_from_db WHERE ts>unix_timestamp(now())-3600;";
   my $SQL="SELECT id_log,hash,ts,line FROM __TABLE__ WHERE ts>unix_timestamp(now())-__LAPSE__ ORDER BY id_log desc;";
   $SQL =~ s/__TABLE__/$tabname/;
   $SQL =~ s/__LAPSE__/$lapse/;

   $self->log('info',"**DEBUG** dbCmd >> $SQL");

   $res = $self->dbSelectAll($dbh,$SQL);
   if ($self->err_num() != 0) {
      $self->log('warning',"ERROR dbCmd >> $SQL");
      $event_info = $self->err_str();
      return (\%data_value,$event_info);
   }


   foreach my $l (@$res) {

		#Si hay pattern definido, el dato lo debe cumplir
#$self->log('info',"pattern=$pattern");
#$self->log('info',"line=$l->[3]");

		if (($pattern ne '') && ($l->[3] !~ /$pattern/)) { next; }

		my $nf = $num_fields;
      my $data = $self->json2h($l->[3]);

		foreach my $field (@fields) {
			if (exists $data->{$field}) {
				$data_value{$field} = $data->{$field};
				$nf--;
			}
		}
		
      $event_info = $l->[3];
      $last_ts = $l->[2];

		if ($nf==0) { last; }
	}

   foreach my $field (@fields) {
      $self->log('info',"**DEBUG** RES $field >> $data_value{$field}");
   }

   return (\%data_value,$event_info,$last_ts);
}

#----------------------------------------------------------------------------
# get_application_data_ext
# Returns ($data_value,$event_info,$last_ts)
# a.  $data_value -> Suma de los valores del dato contenido en el 
#		campo field de las filas que cumplen el patron $params->{'pattern'} 
#		durante la ventana de tiempo now-$params->{'lapse'}
#		Solo se puede especificar un campo field.
# b.  $event_info -> Devuelve el valor de la linea mas reciente que cumple el patron
#     $params->{'pattern'} durante la ventana now-$params->{'lapse'}
# c.  $last_ts -> Ultimo valor de ts (date) almacenado que cumple el patron
#     $params->{'pattern'} durante la ventana now-$params->{'lapse'}
#----------------------------------------------------------------------------
sub get_application_data_ext {
my ($self,$dbh,$params)=@_;


   my $id_app = $params->{'id_app'};
   #my $field = $params->{'field'};
   # Se pueden especificar varios campos separados por "|"
   my @fields = split(/\|/, $params->{'field'});
   my $num_fields = scalar(@fields);

   my $lapse = $params->{'lapse'} || 60;
   $lapse *= 60;
   my $pattern = $params->{'pattern'} || '';
	my $pat = $self->prepare_patterns($pattern);
   # Se pueden especificar varios patrones separados por "|"
	# "|" es la barra para la regex.
	#my $num_patterns = split (/\|/, $pattern);


   $self->err_str('OK');
   $self->err_num(0);

   my %data_value=();
	foreach my $f (@fields) { $data_value{$f}=0; }
   my ($event_info,$last_ts) = ('U','UNK','U');

   # Se obtiene el nombre de la tabla a partir del id.
   # 333333001009 -> logp_333333001009_icgTPVSessions_from_db
   my $res = $self->dbCmd($dbh,"SELECT tabname FROM device2log WHERE tabname LIKE '%$id_app%'");
   if ($res->[0] !~ /log/) {
      $event_info = "**ERROR** NO EXISTE TABLA PARA ID APP $id_app";
      $self->err_str($event_info);
      $self->err_num(1);
      return (\%data_value,$event_info);
   }

   my $tabname = $res->[0];

   #EJ: my $SQL="SELECT id_log,hash,ts,line FROM logp_333333001009_icgTPVSessions_from_db WHERE ts>unix_timestamp(now())-3600;";
   my $SQL="SELECT id_log,hash,ts,line FROM __TABLE__ WHERE ts>unix_timestamp(now())-__LAPSE__ ORDER BY id_log desc;";
   $SQL =~ s/__TABLE__/$tabname/;
   $SQL =~ s/__LAPSE__/$lapse/;

   $self->log('info',"**DEBUG** dbCmd >> $SQL");

   $res = $self->dbSelectAll($dbh,$SQL);
   if ($self->err_num() != 0) {
      $self->log('warning',"ERROR dbCmd >> $SQL");
      $event_info = $self->err_str();
      return (\%data_value,$event_info);
   }

   foreach my $l (@$res) {

		my $data = $self->json2h($l->[3]);
		my $num_ok = $self->check_patterns($data,$pat->{'patterns'});

		my $all_patterns_ok = 0;
      if (($pat->{'pattern_type'} eq 'AND') && ($num_ok == $pat->{'npatterns'})) { $all_patterns_ok = 1; }
		elsif (($pat->{'pattern_type'} eq 'OR') && ($num_ok>0)) { $all_patterns_ok = 1; }

		#$self->log('info',"pattern_type=$pat->{'pattern_type'}  >> all_patterns_ok=$all_patterns_ok");

		if (! $all_patterns_ok) { next; }

		# OPER = sum >> SUMA DE DATOS
		if ($params->{'oper'} =~ /sum/i) {
	      foreach my $field (@fields) {
   	      if ((exists $data->{$field}) && ($data->{$field}=~/^\d+$/)) {
      	      #$self->log('info',"field=$field >> SUMO $data->{$field} >> data_value $data_value{$field}");
         	   $data_value{$field} += $data->{$field};
         	}
      	}
		}
		# OPER = value >> Devuelve el valor del/os campo/s especificados
		else {
      	foreach my $field (@fields) {
         	if (exists $data->{$field}) {
      	      #$self->log('info',"field=$field >> VALUE $data->{$field} >> data_value $data_value{$field}");
            	$data_value{$field} = $data->{$field};
         	}
      	}
		}

      $event_info = $l->[3];
      $last_ts = $l->[2];
   }

#	foreach my $field (@fields) {
#		$self->log('info',"**DEBUG** RES $field >> $data_value{$field}");
#	}

   return (\%data_value,$event_info,$last_ts);
}


#----------------------------------------------------------------------------
# Returns a vector with the lines stored
#----------------------------------------------------------------------------
sub get_application_data_lines {
my ($self,$dbh,$params)=@_;


   my $id_app = $params->{'id_app'};
   my $field = $params->{'field'};
   my $lapse = $params->{'lapse'} || 60;
   $lapse *= 60;


	my ($pattern_cond,$not_pattern_cond,$all_patterns) = ('', '', "line like '%'" );
	if (exists $params->{'pattern'}) { $pattern_cond = "line LIKE '%".$params->{'pattern'}."%'"; }
	if (exists $params->{'not_pattern'}) { $not_pattern_cond = "line NOT LIKE '%".$params->{'pattern'}."%'"; }
	if (($pattern_cond ne '') && ($not_pattern_cond ne '')) { $all_patterns = "$pattern_cond AND $not_pattern_cond";}
	elsif ($pattern_cond ne '') { $all_patterns = $pattern_cond; }
	elsif ($not_pattern_cond ne '') { $all_patterns = $not_pattern_cond; }

	
   #my $pattern = $params->{'pattern'} || '';
   #my $not_pattern = $params->{'not_pattern'} || '';
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
   #my $SQL="SELECT id_log,hash,ts,line FROM __TABLE__ WHERE line like '%__PATTERN__%' AND LINE NOT LIKE '%__NOT_PATTERN__%' AND ts>unix_timestamp(now())-__LAPSE__ ORDER BY id_log desc;";
   my $SQL="SELECT id_log,hash,ts,line FROM __TABLE__ WHERE __ALL_PATTERNS__ AND ts>unix_timestamp(now())-__LAPSE__ ORDER BY id_log desc;";
   $SQL =~ s/__TABLE__/$tabname/;
	#$SQL =~ s/__PATTERN__/$pattern/;
	#$SQL =~ s/__NOT_PATTERN__/$not_pattern/;
	$SQL =~ s/__ALL_PATTERNS__/$all_patterns/;
   $SQL =~ s/__LAPSE__/$lapse/;

   $self->log('info',"**DEBUG** dbCmd >> $SQL");

   $res = $self->dbSelectAll($dbh,$SQL);
   if ($self->err_num() != 0) {
      $self->log('warning',"ERROR dbCmd >> $SQL");
      $event_info = $self->err_str();
      return ($data_value,$event_info);
   }

	my @lines=();
   foreach my $l (@$res) {

      my $data = $self->json2h($l->[3]);
		push @lines,$data;

   }

   return \@lines;

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


#----------------------------------------------------------------------------
# prepare_patterns
# Compone el vector de patrones a partir del parametro especificado en pattern.
# pattern puede ser una lista de condiciones separadas por _AND_ o _OR_
# EJ: clase|eq|Q2_AND_TRANSCOLA|gt|10
# Cada condicion es del tipo: TRANSCOLA|gt|10 o ERRORMSG|eq|"" -> key|operador|value
# Los operadores soportados son: gt, gte, lt, lte, eq, ne
# OUT: $patterns -> Hash con los patrones definidos. Indexado por campo de datos (uc)
# Cada campo contienen un array con los posibles patrones.
# 'kuc' => [ { 'k'=>$k, 'op'=>$op, 'value'=>$value } ]
#----------------------------------------------------------------------------
sub prepare_patterns {
my ($self,$pattern)=@_;


   my @pattern_line = ($pattern);
   my $pattern_type = 'AND';
   if ($pattern =~ /_AND_/) {
      @pattern_line = split (/_AND_/,$pattern);
   }
   elsif ($pattern =~ /_OR_/) {
      @pattern_line = split (/_OR_/,$pattern);
      $pattern_type = 'OR';
   }
	#legacy
	elsif ($pattern =~ /"(.+?)"\:"(.+?)"/) {
		my $pnew = "$1|eqs|$2";
		$self->log('info',"prepare_patterns >> legacy >> $pattern --> $pnew");		
		@pattern_line = ($pnew);
	}

   my %patterns = ();
   foreach my $p (@pattern_line) {
      my ($k,$op,$value) = split(/\|/,$p);
      my $kuc = uc $k;
      if (! exists $patterns{$kuc}) {
         $patterns{$kuc} = [ { 'k'=>$k, 'op'=>$op, 'value'=>$value } ];
      }
      else { push @{$patterns{$kuc}}, { 'k'=>$k, 'op'=>$op, 'value'=>$value }; }

#$self->log('info',"**DEBUG** CLAVE $kuc >> k=$k op=$op value=$value");
   }

	my %result = ();
	$result{'pattern_type'} = $pattern_type;
	$result{'npatterns'} = scalar(keys %patterns);
	$result{'patterns'} = \%patterns;
	return (\%result);

}


#----------------------------------------------------------------------------
# check_patterns
# Valida si el hash k=>v resultado de decodificar la fila en json cumple los
# patrones definidos
# $data -> Hash con los datos de la fila
# $patterns -> Hash con los patrones definidos. Indexado por campo de datos (uc)
# Cada campo contienen un array con los posibles patrones.
# 'kuc' => [ { 'k'=>$k, 'op'=>$op, 'value'=>$value } ]
#----------------------------------------------------------------------------
sub check_patterns {
my ($self,$data,$patterns)=@_;


   my $ok = 0;
   foreach my $k (keys %$data) {

      my $kx = uc $k;
		# Si no hay patron definido para este campo, lo salto.
      if (! exists $patterns->{$kx}) { next; }

#$self->log('info',"**DEBUG** CHECK-CLAVE $kx - pattern=$pattern");

      foreach my $h (@{$patterns->{$kx}})  {

         my $op = $h->{'op'};
         my $value = $h->{'value'};

         #Operandos: eqs, match, ne, gt, lt, gte, lte
         if (($op =~ /eqs/i) && ($data->{$k} eq $value)) { $ok += 1; }
         elsif (($op =~ /match/i) && ($data->{$k} =~/$value/)) { $ok += 1; }
         elsif (($op =~ /gte/i) && ($data->{$k} >= $value)) { $ok += 1; }
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

         #$self->log('info',"check_patterns>> ($kx) --$data->{$k}--$op--$value-- -> ok=$ok");
      }
	}

	return $ok;
}

1;
__END__


