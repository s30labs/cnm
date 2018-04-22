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
#----------------------------------------------------------------------------
sub get_application_events {
my ($self,$dbh,$params)=@_;

	
   my $id_app = $params->{'id_app'};
   my $lapse = $params->{'lapse'} || 60;
	$lapse *= 60;
	my $pattern = $params->{'pattern'} || '';
	$self->err_str('OK');
	$self->err_num(0);


	my ($event_counter,$event_info) = ('U','UNK');
   my $res = $self->dbCmd($dbh,"SELECT tabname FROM device2log WHERE tabname LIKE '%$id_app%'");
   if ($res->[0] !~ /log/) {
		$event_info = "**ERROR** NO EXISTE TABLA PARA ID APP $id_app";
		$self->err_str($event_info);
		$self->err_num(1);
   	return ($event_counter,$event_info);
	}

   my $tabname = $res->[0];

   my $SQL_BASE="SELECT count(*) FROM __TABLE__ WHERE line like '%__PATTERN__%' AND ts>unix_timestamp(now())-__LAPSE__";
   my $SQL=$SQL_BASE;
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

	$self->log('debug',"**DEBUG** dbCmd >> $SQL");

	$SQL_BASE="SELECT substr(line,1,500) FROM __TABLE__ WHERE line like '%__PATTERN__%' AND ts>unix_timestamp(now())-__LAPSE__ ORDER BY id_log desc LIMIT 1";
	$SQL=$SQL_BASE;
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


   return ($event_counter,$event_info);
}

1;
__END__


