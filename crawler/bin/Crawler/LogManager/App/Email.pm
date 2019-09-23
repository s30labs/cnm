#----------------------------------------------------------------------------
# Fichero: Crawler/LogManager/App/Email.pm
# Descripcion:
#----------------------------------------------------------------------------
package Crawler::LogManager::App::Email;
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
use IO::CaptureOutput qw/capture/;
use Net::IMAP::Simple;
use MIME::Parser;
use HTML::TableExtract;
use HTML::Strip;
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
	$self->{_mail_dir} = $arg{mail_dir} || '/home/cnm/correos';
	$self->{_save_mail} = $arg{save_mail} || 0;
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
# mail_dir
#----------------------------------------------------------------------------
sub mail_dir {
my ($self,$mail_dir) = @_;
   if (defined $mail_dir) {
      $self->{_mail_dir}=$mail_dir;
   }
   else { return $self->{_mail_dir}; }
}

#----------------------------------------------------------------------------
# save_mail
# Be careful when storing mails to disk !!!
# Command to remove files older than 30 days.
# find /home/cnm/correos/ -type f -name '*.msg' -mtime +30 -exec rm {} \;
#----------------------------------------------------------------------------
sub save_mail {
my ($self,$save_mail) = @_;
   if (defined $save_mail) {
      $self->{_save_mail}=$save_mail;
   }
   else { return $self->{_save_mail}; }
}

#------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------
# CORE IMAP4
#------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------
   #-------------------------------------------------------------------------------------------
   my %HEAD=();
   my ($TXT,$HTML) = ('','');
   my @MAIL_FILES = ();

#------------------------------------------------------------------------------------------
# CORE-IMAP4 >> app-get-mail-imap4 
# Obtiene correos por IMAP4
# Utiliza un fichero JSON con las credenciales y datos de conexion.
# Resultado: \@RESULT con lineas formadas por:  ts,$app_id,$app_name,source_line
#------------------------------------------------------------------------------------------
sub core_imap_get_app_data {
my ($self,$task_cfg_file)=@_;

	my @RESULT = ();

	my $save_mail = $self->save_mail();
	my $mail_dir = $self->mail_dir();

   # Debe existir el fichero de configuracion de la APP
   if ((! defined $task_cfg_file) && (! -f $task_cfg_file)) {
      $self->log('warning',"core-imap4:: **ERROR** SIN FICHERO DE CONFIGURACION DE LA APP");
      return \@RESULT;
   }

	$self->log('info',"core-imap4:: $task_cfg_file");

	my $app=$self->get_json_config($task_cfg_file);

	# Debe existir el fichero de credenciales IMAP
	if ((! exists $app->[0]->{'credentials'}) && (! -f $app->[0]->{'credentials'})) {
		$self->log('warning',"core-imap4:: **ERROR** SIN CREDENCIALES DE ACCESO");
		return \@RESULT;	
	}

	$self->log('info',"core-imap4:: $app->[0]->{'credentials'}");

	my $x=$self->get_json_config($app->[0]->{'credentials'});

   my $json = JSON->new();
   $json = $json->canonical([1]);

	# Recorre las cuentas de correo definidas
	foreach my $h (@$x) {

   	if (! exists $h->{'imap_host'}) { next; }
	   if (! exists $h->{'imap_user'}) { next; }
   	if (! exists $h->{'imap_pwd'}) { next; }
   	my $port = (exists $h->{'imap_port'}) ? $h->{'imap_port'} : 143;
	   my $timeout = (exists $h->{'imap_timeout'}) ? $h->{'imap_timeout'} : 2;
   	my $use_ssl = (exists $h->{'imap_secure'}) ? $h->{'imap_secure'} : 0;
	   my $mailbox = (exists $h->{'imap_mailbox'}) ? $h->{'imap_mailbox'} : 'INBOX';

	   my $imap = new Net::IMAP::Simple($h->{'imap_host'}, Timeout=>$timeout , ResvPort=>$port, use_ssl=>$use_ssl);

   	if (!defined $imap) { 
			$self->log('warning',"core-imap4:: **ERROR** EN CONEXION IMAP $h->{'imap_host'}/$port (use_ssl=$use_ssl)");
			return \@RESULT;
		}

   	my $r=$imap->login($h->{'imap_user'},$h->{'imap_pwd'});

   	if (! defined $r) { 
         $self->log('warning',"core-imap4:: **ERROR** EN LOGIN IMAP $h->{'imap_user'}/xxxxxxxx | $h->{'imap_host'}/$port (use_ssl=$use_ssl)");
         return \@RESULT;
      }

   	my $nm=$imap->select($mailbox);
		$self->log('info',"core-imap4:: IMAP CONEX OK $nm MSGs in $mailbox");
   	my $parser = new MIME::Parser;
   	#$parser->output_to_core(1);

   	my $FROM_MAIL_FILES_DIR = '/var/www/html/onm/user/files/from_mail';
   	if (! -d $FROM_MAIL_FILES_DIR) { mkdir $FROM_MAIL_FILES_DIR; }
   	$parser->output_dir($FROM_MAIL_FILES_DIR);

	   for(my $i = 1; $i <= $nm; $i++){
   	   my $ts=time();
      	my $seen = $imap->seen($i);
      	my $msize  = $imap->list($i);

	      my $msg = $imap->get( $i ) or die $imap->errstr;
   	   # Necesario para que parse_data interprete un string
      	$msg = "$msg";

			if ($save_mail) {
				open (F, ">$mail_dir/$ts.msg");
				print F "$msg\n";
				close F;
			}


      	%HEAD=();
      	($TXT,$HTML) = ('','');
      	@MAIL_FILES=();
	      my $prefix = int(rand(100000000));
   	   $parser->output_prefix($prefix);

      	my $entity = $parser->parse_data($msg);
			if (! $entity) { 
				$self->log('warning',"core-imap4::app_get_mail_imap4:: **ERROR** en MIME PARSE ($i|$nm)");
				next;
			}

      	$self->dump_entity($entity);

      	my %line = ();
	      $line{'Subject'} = $HEAD{'Subject'};
   	   $line{'From'} = $HEAD{'From'};
      	$line{'From'} =~ s/.+?<(.+)>/$1/;
      	$line{'From'} =~ s/<(.+)>/$1/;	# Por si acaso el From solo tiene <email> (sin nombre)
	      $line{'Date'} = $HEAD{'Date'};
   	   $line{'ts'} = $ts; # Necesario para que cambie el hash md5 que identifica el mensaje
      	$self->log('debug',"core-imap4:: LEIDO MSG $i|$nm (size=$msize leido=$seen) >> From=$line{'From'} | Subject=$line{'Subject'}");

      	#$line{'Message-ID'} = $HEAD{'Message-ID'};
      	#$line{'cnt'} = $i;
	      $line{'body'} = '';
   	   if ($TXT ne '') { $line{'body'} = $TXT; }
	      elsif ($HTML ne '') { $line{'body'} = $HTML; }

   	   $line{'body'} =~ s/\n/ /g;    # Elimina RC
      	$line{'body'} =~ s/\r/ /g;    # Elimina LF
      	$line{'body'} =~ s/\t/ /g;    # Elimina TABS
      	$line{'body'} =~ s/ +/ /g;    # Elimina exceso de espacios

      	#--------------------------------------
			# a. app_id identification
			# b. variable detection if defined (S1,B1)
	      my ($app_id,$app_name) = $self->mail_app_mapper($app,\%line);

      	#--------------------------------------
			# c. extrafile detection
   	   my $APP_FILES_DIR = '/var/www/html/onm/user/files/'.$app_name;
      	if (! -d $APP_FILES_DIR) { mkdir $APP_FILES_DIR; }
	      my $j=1;
   	   foreach my $fpath (@MAIL_FILES) {

				my $f = '';
				if ($fpath=~/$FROM_MAIL_FILES_DIR\/(.+)$/) { $f = $prefix.'-'.$1; }
				$f=~s/\s+//g;

      	   `mv \"$fpath\" $APP_FILES_DIR/$f`;
$self->log('info',"core-imap4::***DEBUG mv [$j]*** mv $fpath $APP_FILES_DIR");

         	my $k = '0extrafile'.$j;

	         #my $f = '';
   	     # if ($fpath=~/$FROM_MAIL_FILES_DIR\/(.+)$/) { $f = $1; }

 	        $line{$k} = "<html><a href=user/files/$app_name/$f target=\"popup\">$k</a></html>";

   	      $self->log('debug',"core-imap4::***DEBUG [$j]*** $k >> $line{$k}");
      	   $j++
      	}

      	#--------------------------------------
		   my %MSG = ();
   		$MSG{'source_line'} = $json->encode(\%line);
   		$MSG{'ts'} = $ts;
   		$MSG{'source_line'} =~ s/","/", "/g;

      	push @RESULT, join (',',$MSG{'ts'},$app_id,$app_name,$MSG{'source_line'});
      	#--------------------------------------

      	$imap->delete($i);
   	}

   	if ($nm>0) {
     	 	my $expunged = $imap->expunge_mailbox($mailbox);
   	}

   	$imap->quit();
   	undef $imap;
	}

#	foreach my $l (@RESULT) {
#   	print "$l\n";
#	}

	return \@RESULT;


}


#------------------------------------------------------------------------------------------
# test_msg_flow
#------------------------------------------------------------------------------------------
sub test_msg_flow {
my ($self,$task_cfg_file,$file_msg)=@_;


	my @RESULT=();
	my $app=$self->get_json_config($task_cfg_file);
	
   my $parser = new MIME::Parser;

   my $FROM_MAIL_FILES_DIR = '/var/www/html/onm/user/files/from_mail';
   if (! -d $FROM_MAIL_FILES_DIR) { mkdir $FROM_MAIL_FILES_DIR; }
   $parser->output_dir($FROM_MAIL_FILES_DIR);

	my $msg = $self->slurp_file($file_msg);

   %HEAD=();
   ($TXT,$HTML) = ('','');
   @MAIL_FILES=();
   my $prefix = int(rand(100000000));
   $parser->output_prefix($prefix);

   my $entity = $parser->parse_data($msg);
   if (! $entity) {
      $self->log('warning',"core-imap4::test_msg_flow:: **ERROR** en MIME PARSE ($file_msg)");
      return;
   }

   $self->dump_entity($entity);


   my %line = ();
	my $ts=time();
   $line{'Subject'} = $HEAD{'Subject'};
   $line{'From'} = $HEAD{'From'};
   $line{'From'} =~ s/.+?<(.+)>/$1/;
   $line{'From'} =~ s/<(.+)>/$1/;	# Por si acaso el From solo tiene <email> (sin nombre)
   $line{'Date'} = $HEAD{'Date'};
   $line{'ts'} = $ts; # Necesario para que cambie el hash md5 que identifica el mensaje
   $self->log('debug',"core-imap4:: LEIDO MSG ($file_msg) >> From=$line{'From'} | Subject=$line{'Subject'}");

   $line{'body'} = '';
   if ($TXT ne '') { $line{'body'} = $TXT; }
   elsif ($HTML ne '') { $line{'body'} = $HTML; }

   $line{'body'} =~ s/\n/ /g;    # Elimina RC
   $line{'body'} =~ s/\r/ /g;    # Elimina LF
   $line{'body'} =~ s/\t/ /g;    # Elimina TABS
   $line{'body'} =~ s/ +/ /g;    # Elimina exceso de espacios

   #--------------------------------------
   # a. app_id identification
   # b. variable detection if defined (S1,B1)
   my ($app_id,$app_name) = $self->mail_app_mapper($app,\%line);

   #--------------------------------------
   # c. extrafile detection
   my $APP_FILES_DIR = '/var/www/html/onm/user/files/'.$app_name;
   if (! -d $APP_FILES_DIR) { mkdir $APP_FILES_DIR; }
   my $j=1;
   foreach my $fpath (@MAIL_FILES) {

      my $f = '';
      if ($fpath=~/$FROM_MAIL_FILES_DIR\/(.+)$/) { $f = $prefix.'-'.$1; }
      $f=~s/\s+//g;

      `mv \"$fpath\" $APP_FILES_DIR/$f`;
$self->log('info',"core-imap4::***DEBUG mv [$j]*** mv $fpath $APP_FILES_DIR");

      my $k = '0extrafile'.$j;
		
     	$line{$k} = "<html><a href=user/files/$app_name/$f target=\"popup\">$k</a></html>";

     	$self->log('debug',"core-imap4::***DEBUG [$j]*** $k >> $line{$k}");
      $j++
   }

   #--------------------------------------
	my $json = JSON->new();
	$json = $json->canonical([1]);

   my %MSG = ();
   $MSG{'source_line'} = $json->encode(\%line);
   $MSG{'ts'} = $ts;
	$MSG{'source_line'} =~ s/","/", "/g;

   push @RESULT, join (',',$MSG{'ts'},$app_id,$app_name,$MSG{'source_line'});
   #--------------------------------------

   return \@RESULT;

}


#-------------------------------------------------------------------------------------------
# CORE-IMAP4 >>  mail_app_mapper
# Asigna los datos recibidos por correo a una app_id
# (Siempre se asigna a una app_id. Si no matchea -> default) 
#-------------------------------------------------------------------------------------------
#      {
#         "333333000008" : {
#            "B1" : "(?i)Application\\s+\\:\\s+(\\S+)",
#            "From" : "info@s30labs.com",
#            "Subject" : "ERROR xyz",
#            "app_name" : "my-App"
#				 "body_format" : "txt"
#				 "host" : "my-host"
#         }
#      },
#
# B1: Permite extraer una parte del body como la variable B1 en el json de la linea.
# S1: Permite extraer una parte del asunto como la variable S1 en el json de la linea.
# From: Indica el criterio basado en el From para identificar la app
# Subject: Indica el criterio basado en el Subject para identificar la app
# body_format: Formato del body almacenado en source_line. Si no existe es el que tenga por defecto
#					segun el content-type. Si vale 'txt', se eliminan los tags html
# app_name: Nombre de la app
#-------------------------------------------------------------------------------------------
sub mail_app_mapper {
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
			$self->log('info',"core-imap4::mail_app_mapper:: check_from: $app_id >> in rule: $h->{$app_id}->{'From'} rx: $line->{'From'}--");
         if ($line->{'From'} ne $h->{$app_id}->{'From'}) {
            $ok=0;
				$self->log('debug',"core-imap4::mail_app_mapper:: check_from: $app_id >> ok=$ok >> END");
            next;
         }
      }

      # Hay que validar subject
      if (exists $h->{$app_id}->{'Subject'}) {
			$self->log('info',"core-imap4::mail_app_mapper:: check_subject: $app_id >> in rule: $h->{$app_id}->{'Subject'} rx: $line->{'Subject'}--");
         my $rule_subject = $h->{$app_id}->{'Subject'};
         if ($line->{'Subject'} !~ /$rule_subject/) {
            $ok=0;
				$self->log('debug',"core-imap4::mail_app_mapper:: check_subject: $app_id >> ok=$ok >> END");
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
		$self->log('info',"core-imap4::mail_app_mapper:: MAIL-MAPPED TO default app_id=$app_id | app_name=$app_name");
   }
	else {
		$self->log('info',"core-imap4::mail_app_mapper:: MAIL-MAPPED TO app_id=$app_id | app_name=$app_name");
	}


   #----------------------------------------------------------------------------------------
   # b. variable detection
   #----------------------------------------------------------------------------------------
#my $kk=Dumper($app_cfg);
#$kk=~s/\n/ /g;
#$self->log('debug',"core-imap4::mail_app_mapper:: **DEBUGVAR** ----$kk----");

   $line->{'S1'} = '';
   if (exists $app_cfg->{'S1'}){
      my $exp=$app_cfg->{'S1'};
      if ($line->{'Subject'}=~/$exp/g) { 
			$line->{'S1'} = $1; 
			$self->log('info',"core-imap4::mail_app_mapper:: **VAR FOUND** S1=$line->{'S1'} |  app_id=$app_id | app_name=$app_name");
		}
$self->log('debug',"core-imap4::mail_app_mapper:: **DEBUGVAR** S1 exp=$exp | RES=$line->{'S1'} | Subject=$line->{'Subject'} |  app_id=$app_id | app_name=$app_name");
   }

	$line->{'B1'} = '';
	if (exists $app_cfg->{'B1'}){
		my $exp=$app_cfg->{'B1'};
		if ($line->{'body'}=~/$exp/g) { 
			$line->{'B1'} = $1; 
			$self->log('info',"core-imap4::mail_app_mapper:: **VAR FOUND** B1=$line->{'B1'} |  app_id=$app_id | app_name=$app_name");
		}
$self->log('debug',"core-imap4::mail_app_mapper:: **DEBUGVAR** B1 exp=$exp | RES=$line->{'B1'} | body=$line->{'body'} |  app_id=$app_id | app_name=$app_name");
	}


   #----------------------------------------------------------------------------------------
   # c. Convert HTML body to TXT if exists body_format = 'txt'
   #----------------------------------------------------------------------------------------
	if ( (exists $app_cfg->{'body_format'}) && ($app_cfg->{'body_format'}=~/txt/i) ) {
      my $hs = HTML::Strip->new();
		my $body = $line->{'body'};
      $line->{'body'} = $hs->parse($body);
      $hs->eof;
	}

   return ($app_id,$app_name);
}



#-------------------------------------------------------------------------------------------
# CORE-IMAP4 >> dump_entity
#-------------------------------------------------------------------------------------------
sub dump_entity {
my ($self,$entity, $name) = @_;

   if (! defined($name)) {
      $name = "'anonymous'";
      $HEAD{'Subject'} = $entity->head->get('Subject');
      $HEAD{'From'} = $entity->head->get('From');
      $HEAD{'To'} = $entity->head->get('To');
      $HEAD{'Return-Path'} = $entity->head->get('Return-Path');
      $HEAD{'Received'} = $entity->head->get('Received');
      $HEAD{'Date'} = $entity->head->get('Date');
      $HEAD{'Message-ID'} = $entity->head->get('Message-ID');
      chomp $HEAD{'Subject'};
      chomp $HEAD{'From'};
      chomp $HEAD{'To'};
      chomp $HEAD{'Return-Path'};
      chomp $HEAD{'Received'};
      chomp $HEAD{'Date'};
      chomp $HEAD{'Message-ID'};
   }

   # Output the body:
   my @parts = $entity->parts;
   if (@parts) {                     # multipart...
      my $i;
      foreach $i (0 .. $#parts) {       # dump each part...
         $self->dump_entity($parts[$i], ("$name, part ".(1+$i)));
      }
   }
   else {                            # single part...
      # Get MIME type, and display accordingly...
      my ($type, $subtype) = split('/', $entity->head->mime_type);
      my $body = $entity->bodyhandle;
      my $path = $body->path();

#      my $path_new = $path;
#      if ($path_new=~/\s+/) {
#         $path_new=~s/\s+/_/g;
#         `mv \"$path\" $path_new`;
#			$self->log('info',"core-imap4::dump_entity:: ****DEBUG**** mv \"$path\" $path_new");
#      }
#      push @MAIL_FILES, $path_new;

      push @MAIL_FILES, $path;


      #Content-Type: text/plain
      #Content-Type: text/html
      if ($type =~ /^(text|message)$/) {     # text: display it...

#print '-'x80,"\n";
#print $entity->head->get('Content-type')."\n";
#print '-'x80,"\n";
#print $body->as_string();
#print '-'x80,"\n";

         my $ctype=$entity->head->get('Content-type');
         if ($ctype =~ /text\/plain/) {
            $TXT = $body->as_string();
         }
         elsif ($ctype =~ /text\/html/) {
            $HTML = $body->as_string();
         }
         else {
				$self->log('info',"core-imap4::dump_entity:: Content-type DESCONOCIDO ($ctype)");
         }
      }
   }
}



1;
__END__


