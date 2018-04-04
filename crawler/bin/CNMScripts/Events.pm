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


   my $res = $self->dbCmd($dbh,"SELECT tabname FROM device2log WHERE tabname LIKE '%$id_app%'");
   if ($res->[0] !~ /log/) {
		$self->err_str("**ERROR** NO EXISTE TABLA PARA ID APP $id_app");
		$self->err_num(1);
		return 0;
	}

   my $tabname = $res->[0];

   my $SQL_BASE="SELECT count(*) FROM __TABLE__ WHERE line like '%__PATTERN__%' AND ts>unix_timestamp(now())-__LAPSE__";
   my $SQL=$SQL_BASE;
   $SQL =~ s/__TABLE__/$tabname/;
   $SQL =~ s/__PATTERN__/$pattern/;
   $SQL =~ s/__LAPSE__/$lapse/;


   $res = $self->dbCmd($dbh,$SQL);
	my $event_counter = $res->[0];

	$SQL_BASE="SELECT substr(line,1,500) FROM __TABLE__ WHERE line like '%__PATTERN__%' AND ts>unix_timestamp(now())-__LAPSE__ ORDER BY id_log desc LIMIT 1";
	$SQL=$SQL_BASE;
   $SQL =~ s/__TABLE__/$tabname/;
   $SQL =~ s/__PATTERN__/$pattern/;
   $SQL =~ s/__LAPSE__/$lapse/;

#print "$SQL\n";

   $res = $self->dbCmd($dbh,$SQL);
   my $event_info = $res->[0];

#print "$event_info---\n";

   return ($event_counter,$event_info);
}

1;
__END__


