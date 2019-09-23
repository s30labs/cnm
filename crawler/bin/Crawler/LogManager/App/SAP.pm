#----------------------------------------------------------------------------
# Fichero: Crawler/LogManager/App/SAP.pm
# Descripcion:
#----------------------------------------------------------------------------
package Crawler::LogManager::App::SAP;
use Crawler::LogManager::App;
use lib '/cfg/modules/';
@ISA=qw(Crawler::LogManager::App);
$VERSION='1.00';
use strict;
use POSIX ":sys_wait_h";
use Digest::MD5 qw(md5_hex);
use Data::Dumper;
use Time::HiRes;
use File::Basename;
use JSON;
use YAML;
use Time::Local;
use File::Copy;
use IO::CaptureOutput qw/capture/;
use Net::IMAP::Simple;
use MIME::Parser;
use HTML::TableExtract;

#----------------------------------------------------------------------------
#----------------------------------------------------------------------------

#----------------------------------------------------------------------------
use constant STAT_BAJA => 1;
use constant STAT_MANT => 2;
use constant STAT_ERASE => 3;

#----------------------------------------------------------------------------

#----------------------------------------------------------------------------
#----------------------------------------------------------------------------
#----------------------------------------------------------------------------
#----------------------------------------------------------------------------

#----------------------------------------------------------------------------
# Funcion: Constructor
# Descripcion: Crea un objeto del tipo Crawler::App
#----------------------------------------------------------------------------
sub new {
my ($class,%arg) =@_;

   my $self=$class->SUPER::new(%arg);
	$self->{_cfg} = $arg{cfg} || 0;
   return $self;

}


#---------------------------------------------------------------------------
# cfg
#----------------------------------------------------------------------------
sub cfg {
my ($self,$cfg) = @_;
   if (defined $cfg) {
      $self->{_cfg}=$cfg;
   }
   else { return $self->{_cfg}; }
}

#------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------

#------------------------------------------------------------------------------------------
# CORE-IMAP4 >> app-get-mail-imap4 
# Obtiene correos por IMAP4
# Utiliza un fichero JSON con las credenciales y datos de conexion.
# Resultado: \@RESULT con lineas formadas por:  ts,$app_id,$app_name,source_line
#------------------------------------------------------------------------------------------
sub core_sap_get_app_data {
my ($self,$task_cfg_file)=@_;

	my @RESULT = ();

   # Debe existir el fichero de configuracion de la APP
	# EJ: /opt/cnm-areas/cfg/crawler-app/app-33333300102x-idocs.json
   if ((! defined $task_cfg_file) && (! -f $task_cfg_file)) {
      $self->log('warning',"core-sap:: **ERROR** SIN FICHERO DE CONFIGURACION DE LA APP");
      return \@RESULT;
   }

	$self->log('info',"core-sap:: $task_cfg_file");

	my $app=$self->get_json_config($task_cfg_file);

	# Debe existir el fichero de credenciales SAP
	# EJ: /opt/cnm-areas/cfg/sap-manager/areas_prawwerpdb01.json
	if ((! exists $app->[0]->{'credentials'}) && (! -f $app->[0]->{'credentials'})) {
		$self->log('warning',"core-sap:: **ERROR** SIN CREDENCIALES DE ACCESO");
		return \@RESULT;	
	}

	$self->log('info',"core-sap:: $app->[0]->{'credentials'}");

	my $x=$self->get_json_config($app->[0]->{'credentials'});


	# Suponemos solo una credencial definida para SAP
	my $host = $x->[0]->{'sap_host'};
	my $port = $x->[0]->{'sap_port'};
	my $user = $x->[0]->{'sap_user'};
	my $pwd = $x->[0]->{'sap_pwd'};


	# mapper contiene el ARRAY de descriptores para cada app_id con todos los dadtos de cada query
   foreach my $h (@{$app->[0]->{'mapper'}}) {
		#print Dumper($h);
#$h = {
#          '333333001020' => {
#                              'app_name' => 'idocs-pedido-no-exportado',
#                              'sql' => 'SELECT E.DOCNUM, E.DOCREL, E.STATUS, E.DIRECT, CASE WHEN E.DIRECT = 1 THEN \'Outbound - SAP to Prov\' ELSE \'Inbound -Prov to SAP\' END AS DESC, E.CREDAT, E.CRETIM, MAX(ES.STATXT) AS TXT FROM "SAPS4FIN"."EDIDC" E, "SAPS4FIN"."EDIDS" ES WHERE E.DOCNUM = ES.DOCNUM AND E.MESTYP = \'ORDERS\' AND E.STATUS NOT IN (\'03\',\'53\',\'52\',\'68\',\'69\',\'70\',\'12\',\'31\',\'32\') GROUP BY E.DOCNUM, E.DOCREL, E.STATUS, E.DIRECT, E.CREDAT, E.CRETIM ORDER BY E.CREDAT DESC',
#                              'fields' => 'DOCNUM,DOCREL,STATUS,DIRECT,DESC,CREDAT,CRETIM,TXT',
#                              'capture_mode' => 'flush'
#                            }
#        };

		my @k = keys %$h;
		my $APP_ID = $k[0];
		my $APP_NAME = $h->{$APP_ID}->{'app_name'};
		my $sql = $self->prepare_sql($h->{$APP_ID}->{'sql'});
		my @FIELDS = split(',', $h->{$APP_ID}->{'fields'});
		my $capture_mode = $h->{$APP_ID}->{'capture_mode'};
		my $subtitle_txt = $h->{$APP_ID}->{'subtitle'};
		my $date_fields = exists ($h->{$APP_ID}->{'date_fields'}) ? $h->{$APP_ID}->{'date_fields'} : '';
		my $date_format = exists ($h->{$APP_ID}->{'date_format'}) ? $h->{$APP_ID}->{'date_format'} : '';


#print "APP_ID=$APP_ID\tAPP_NAME=$APP_NAME----\n";
		#-------------------------------------------------------------------------------------------
		# Script executed inside SAP Hana container
		# user=SVCAVANTIMONITORERP,pwd=Av4nt1m0n1t0r,host=prawwerpdb01.areascloud.com,port=30041,sqlcmd='select * from "SAPS4FIN"."YMC_DAYVALINV";'
		#-------------------------------------------------------------------------------------------
		my $TIMEOUT=30;
		my $CSCRIPT_PATH_IN_HOST='/persistent/saphana/sql';
		my $CSCRIPT_PATH='/mnt/sql';
		my $scratch=int(1000000*rand);
		my $CSCRIPT_NAME=$scratch.'.sh';
		my $CSQL_NAME=$scratch.'.sql';

		#my $CSCRIPT='#!/bin/bash
		#
		#/usr/sap/hdbclient/hdbuserstore -v SET SVCAVANTIMONITORERP prawwerpdb01.areascloud.com:30041 SVCAVANTIMONITORERP Av4nt1m0n1t0r > /dev/null 2>&1
		#/usr/sap/hdbclient/hdbsql -U SVCAVANTIMONITORERP -I /mnt/sql/command.sql
		#
		#';
		my $CSCRIPT="#!/bin/bash

/usr/sap/hdbclient/hdbuserstore -v SET $user $host:$port $user $pwd > /dev/null 2>&1
/usr/sap/hdbclient/hdbsql -U $user -I $CSCRIPT_PATH/$CSQL_NAME

";

		#-------------------------------------------------------------------------------------------
		my %EXTRAFILE = ();
		my $DOC_SUBDIR = 'user/files/'.$APP_NAME;
		my $FILE_DIR = '/var/www/html/onm/'.$DOC_SUBDIR;

		#-------------------------------------------------------------------------------------------
		my $ts = time;
   	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($ts);
   	$year += 1900;
   	$mon += 1;
      my $ts_str = sprintf("%04d-%02d-%02d %02d:%02d:%02d",$year,$mon,$mday,$hour,$min,$sec);

		#-------------------------------------------------------------------------------------------
		# DATA Capture
		#-------------------------------------------------------------------------------------------
		#docker run --rm -v /persistent/saphana/sql:/mnt/sql saphana bash -c "/mnt/sql/do.sh"
		open (F,">$CSCRIPT_PATH_IN_HOST/$CSCRIPT_NAME");
		print F $CSCRIPT;
		close F;
		chmod 0755, "$CSCRIPT_PATH_IN_HOST/$CSCRIPT_NAME";
		open (F,">$CSCRIPT_PATH_IN_HOST/$CSQL_NAME");
		print F $sql;
		close F;


		my $CMD="docker run --rm --stop-timeout $TIMEOUT -v $CSCRIPT_PATH_IN_HOST:$CSCRIPT_PATH saphana bash -c $CSCRIPT_PATH/$CSCRIPT_NAME";

		$self->log('debug',"core-sap::sap_app_mapper:: sql=$sql");
		$self->log('debug',"core-sap::sap_app_mapper:: CMD=$CMD");

#print "sql=$sql\n";
#print "CMD=$CMD\n";

		my @lines =`$CMD`;

#print Dumper (\@lines);

		#if ($VERBOSE) { print Dumper (\@lines); }

		unlink "$CSCRIPT_PATH_IN_HOST/$CSCRIPT_NAME";
		unlink "$CSCRIPT_PATH_IN_HOST/$CSQL_NAME";

		#-------------------------------------------------------------------------------------------
		# DATA Parser
		#-------------------------------------------------------------------------------------------
		my $json = JSON->new();
		$json = $json->canonical([1]);

		my ($c1,$c2) = (0,0);


		foreach my $l (@lines) {
   		if (! defined $l) { next; }

		   chomp $l;
   		#$crawler->log('debug',"custom_parser:: LINE: $l");
	
   		# Salto cabeceras
	   	if ($l =~ /$FIELDS[0]/) {next;}

		   my %line=();
   		my @col = split(',', $l);
	   	my $i=0;
   		foreach my $field (@FIELDS) {
      		$line{$FIELDS[$i]} = ($col[$i]=~/"([^"]*)"/) ? $1 : $col[$i];
	      	$i++;
   		}

			if ($date_fields ne '') { $line{'CNM_ts'} = $ts_str; }

	   	$line{'CNM_Flag'} = '01';
	   	my $subtitle = "$c2 : $subtitle_txt";
   		$c2++;

	   	my $filekey = $line{'CNM_Flag'};
   		$EXTRAFILE{$filekey}=1;

		   if (! -d $FILE_DIR) { mkdir $FILE_DIR; }
   		my $filename = $filekey.'.txt';
	   	my $file_temp = $FILE_DIR.'/'.$filename.'.tmp';
	   	$line{'extrafile2'} = '<html><a href='.$DOC_SUBDIR.'/'.$filename." target=&quot;popup&quot;>extrafile2</a></html>";

		   open (F,">>$file_temp");
   		print F 'x'x80,"\n";
	   	print F "$subtitle\n";
  		 	print F 'x'x80,"\n";
   		foreach my $k (sort keys(%line)) {
      		print F "$k = ".$line{$k}."\n";
   		}
	   	print F "\n\n";
   		close F;

	   	#--------------------------------------
	   	my %MSG = ();
   		$MSG{'source_line'} = $json->encode(\%line);
   		$MSG{'source_line'} =~ s/","/", "/g;
   		#$MSG{'source_line'} .= ':::'.$md5_line;

		   $MSG{'ts'} = ($date_fields eq '') ? $ts : $self->prepare_date($date_fields,$date_format,\%line);
   		push @RESULT, join (',',$MSG{'ts'},$APP_ID,$APP_NAME,$MSG{'source_line'});
   		#--------------------------------------

		}


		# Una vez terminado el bloque se cierran los ficheros extrafile2
		foreach my $f (keys %EXTRAFILE) {

   		my $filename = $f.'.txt';
	   	my $file_temp = $FILE_DIR.'/'.$filename.'.tmp';
   		my $file_ok = $FILE_DIR.'/'.$filename;
	
		   if ( (-f $file_temp) && (-s $file_temp) ) {
   	 		my $rc = copy($file_temp,$file_ok);
      		unlink $file_temp;
   		}
		}
	}

#print Dumper(\@RESULT);

	return \@RESULT;


}



#-------------------------------------------------------------------------------------------
# prepare_date
# EJ:
# date_fields -> CREDAT,CRETIM 
# date_format -> AAAAMMDD,HHMMSS 
#-------------------------------------------------------------------------------------------
sub prepare_date {
my ($self,$date_fields,$date_format,$line) = @_;

	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst);
	my @dfields = split (',', $date_fields);
	my @dformats = split (',', $date_format);
	my $i = -1;
	foreach my $f (@dformats) {
		$i++;
		if ($f =~/AAAAMMDD/) { 
			if ($line->{$dfields[$i]} =~ /(\d{4})(\d{2})(\d{2})/)  { 
				($year,$mon,$mday)=($1,$2,$3);
			}
			next;
		}
      if ($f =~/HHMMSS/) {
         if ($line->{$dfields[$i]} =~ /(\d{2})(\d{2})(\d{2})/)  {
            ($hour,$min,$sec)=($1,$2,$3);
         }
			next;
      }
	}

	$self->log('info',"prepare_date:: hour=$hour,min=$min,sec=$sec - mday=$mday,mon=$mon,year=$year - ts=ts");
	$mon-=1;
	$year-=1900;
   my $ts = timelocal($sec,$min,$hour,$mday,$mon,$year);

	return $ts;

}


#-------------------------------------------------------------------------------------------
# prepare_sql
#-------------------------------------------------------------------------------------------
sub prepare_sql {
my ($self,$sql) = @_;

	my $ts = time();
   my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($ts);
   $year += 1900;
   $mon += 1;

	if ($sql =~ /__AAAAMMDD__/i) {
		my $amd = sprintf("%04d%02d%02d",$year,$mon,$mday);
		$sql =~ s/__AAAAMMDD__/$amd/g;
	}

   if ($sql =~ /__HHMMSS__/i) {
      my $hms = sprintf("%02d%02d%02d",$hour,$min,$sec);
      $sql =~ s/__HHMMSS__/$hms/g;
   }
   elsif ($sql =~ /__HHMMSS-(\d+)h__/i) {
		my $ts_nh =  $ts-($1*3600);
		my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($ts_nh);
	   $year += 1900;
   	$mon += 1;
      my $hms = sprintf("%02d%02d%02d",$hour,$min,$sec);
      $sql =~ s/__HHMMSS-\d+h__/$hms/g;
   }


	return $sql;
}


#-------------------------------------------------------------------------------------------
# CORE-IMAP4 >>  sap_app_mapper
# Asigna los datos recibidos por correo a una app_id
# (Siempre se asigna a una app_id. Si no matchea -> default) 
#-------------------------------------------------------------------------------------------
sub sap_app_mapper {
my ($self,$app,$line) = @_;

   my ($ok,$app_id,$app_name,$app_cfg) = (1,'','',{});

	#----------------------------------------------------------------------------------------
	# a. app_id detection
	#----------------------------------------------------------------------------------------
   foreach my $h (@{$app->[0]->{'mapper'}}) {
      my @k = keys %$h;
      $app_id = $k[0];
      $ok=1;

      # Hay que validar From
      if (exists $h->{$app_id}->{'From'}) {
			$self->log('info',"core-sap4::sap_app_mapper:: CHECK1: $app_id >> From=$h->{$app_id}->{'From'} <> $line->{'From'}--");
         if ($line->{'From'} ne $h->{$app_id}->{'From'}) {
            $ok=0;
				$self->log('debug',"core-sap4::sap_app_mapper:: CHECK1: $app_id >> ok=$ok >> END");
            next;
         }
      }

      # Hay que validar subject
      if (exists $h->{$app_id}->{'Subject'}) {
			$self->log('info',"core-sap4::sap_app_mapper:: CHECK2: $app_id >> Subject=$h->{$app_id}->{'Subject'} <> $line->{'Subject'}--");
         my $rule_subject = $h->{$app_id}->{'Subject'};
         if ($line->{'Subject'} !~ /$rule_subject/) {
            $ok=0;
				$self->log('debug',"core-sap4::sap_app_mapper:: CHECK2: $app_id >> ok=$ok >> END");
            next;
         }
      }

      if ($ok) {
         $app_name = $h->{$app_id}->{'app_name'};
			$app_cfg = $h->{$app_id};
         last;
      }
   }

   if (! $ok) {
		$app_cfg = $app->[0]->{'default'};
      ($app_id,$app_name) = ($app->[0]->{'default'}->{'app_id'}, $app->[0]->{'default'}->{'app_name'});
		$self->log('info',"core-sap4::sap_app_mapper:: MAPPED TO default app_id=$app_id | app_name=$app_name");
   }
	else {
		$self->log('info',"core-sap4::sap_app_mapper:: MAPPED TO app_id=$app_id | app_name=$app_name");
	}


   #----------------------------------------------------------------------------------------
   # b. variable detection
   #----------------------------------------------------------------------------------------
#my $kk=Dumper($app_cfg);
#$kk=~s/\n/ /g;
#$self->log('debug',"core-sap4::sap_app_mapper:: **DEBUGVAR** ----$kk----");

   $line->{'S1'} = '';
   if (exists $app_cfg->{'S1'}){
      my $exp=$app_cfg->{'S1'};
      if ($line->{'Subject'}=~/$exp/g) { 
			$line->{'S1'} = $1; 
			$self->log('info',"core-sap4::sap_app_mapper:: **VAR FOUND** S1=$line->{'S1'} |  app_id=$app_id | app_name=$app_name");
		}
$self->log('debug',"core-sap4::sap_app_mapper:: **DEBUGVAR** S1 exp=$exp | RES=$line->{'S1'} | Subject=$line->{'Subject'} |  app_id=$app_id | app_name=$app_name");
   }

	$line->{'B1'} = '';
	if (exists $app_cfg->{'B1'}){
		my $exp=$app_cfg->{'B1'};
		if ($line->{'body'}=~/$exp/g) { 
			$line->{'B1'} = $1; 
			$self->log('info',"core-sap4::sap_app_mapper:: **VAR FOUND** B1=$line->{'B1'} |  app_id=$app_id | app_name=$app_name");
		}
$self->log('debug',"core-sap4::sap_app_mapper:: **DEBUGVAR** B1 exp=$exp | RES=$line->{'B1'} | body=$line->{'body'} |  app_id=$app_id | app_name=$app_name");
	}

   return ($app_id,$app_name);
}


1;
__END__


