#!/usr/bin/perl -w
#-------------------------------------------------------------------------------------------
use lib "/opt/crawler/bin";
use lib "/cfg/modules";
use strict;
use Getopt::Std;
use ONMConfig;
use Crawler::Notifications;
use Data::Dumper;


#-------------------------------------------------------------------------------------------
my $TEMPLATE='
__SET_CLR_ALERT__

__ALERT_CAUSE__
__DATE__
__DEVICE__ - __IP__

__EVENT_DATA__ : Texto con el evento.

URL con el detalle de la alerta: __URL__

NOMBRE.DOMINIO: __DEVICE__
IP -
__IP__
LOCALIZACION:
__SYSLOC__
DESCRIPCION: __SYSDESC__
OID: __SYSOID__
MAC: __MAC__
CRIT: __CRITIC__
TIPO: __TYPE__
ESTADO: __STATUS__
COMUNIDAD: __COMMUNITY__
VERSION: __VERSION__

GEODATA: __GEODATA__
SERVICIO: __SERVICIO__
GRUPO RESPONSABLE: __GRUPO RESPONSABLE__
UBICACION: __UBICACION__
RACK: __RACK__
FABRICANTE: __FABRICANTE__
MODELO: __MODELO__
N.SERIE: __N.SERIE__
N.ACTIVO: __N.ACTIVO FIJO__
SISTEMA OPERATIVO: __SISTEMA OPERATIVO__
FUNCION PRINCIPAL: __FUNCION PRINCIPAL__
SOFTWARE PRINCIPAL: __SOFTWARE PRINCIPAL__
EMPRESA MANTENIMIENTO: __EMPRESA MANTENIMIENTO__

SOPORTE: __SOPORTE__
AREA DE TRABAJO: __AREA DE TRABAJO__
DIRECCION CORREO AREA DE TRABAJO: __DIRECCION CORREO AREA DE TRABAJO__
IDENTIFICADOR LINEA DATOS: __IDENTIFICADOR LINEA DATOS__
TELEFONO CONTACTO APARCAMIENTO: __TELEFONO CONTACTO APARCAMIENTO__
JEFE APARCAMIENTO: __JEFE APARCAMIENTO__
TELEFONO JEFE APARCAMIENTO: __TELEFONO JEFE APARCAMIENTO__
CIF APARCAMIENTO: __CIF APARCAMIENTO__
FAMILIA SERVICIO: __FAMILIA SERVICIO__
COMPONENTE DE INFRAESTRUCTURA: __COMPONENTE DE INFRAESTRUCTURA__
DIRECCION: __DIRECCION__
EMPLAZAMIENTO: __EMPLAZAMIENTO__
URL: __URL__
SOCIEDAD: __SOCIEDAD__
SISTEMA: __SISTEMA__
SUBSISTEMA: __SUBSISTEMA__
COMPONENTE: __COMPONENTE__
';
#-------------------------------------------------------------------------------------------
my $STORE_PATH='/opt/data/rrd/';
my $FILE_CONF='/cfg/onm.conf';

#-------------------------------------------------------------------------------------------
my $set_clr='SET';
my $url='http://www.s30labs.com';
my @ALERT=(3341,0);

#From Notifications.pm
#use constant aDEVICE => 0;
#use constant aALERT_TYPE=> 1;
#use constant aALERT_CAUSE=> 2;
#use constant aALERT_DEV_NAME=> 3;
#use constant aALERT_DEV_DOMAIN=> 4;
#use constant aALERT_DEV_IP=> 5;
#use constant aNOTIF=> 6;
#use constant aID_ALERT=> 7;
#use constant aMNAME=> 8;
#use constant aWATCH=> 9;
#use constant aEVENT_DATA=> 10;
#use constant aACK=> 11;
#use constant aID_TICKET=> 12;
#use constant aSEVERITY=> 13;
#use constant aTYPE=> 14;
#use constant aDATE=> 15;
#use constant aCOUNTER=> 16;
#use constant aID_METRIC=> 17;

#-------------------------------------------------------------------------------------------
#-------------------------------------------------------------------------------------------
my $rcfgbase=conf_base($FILE_CONF);
#my $LAPSE=$rcfgbase->{notif_lapse}->[0];
my $MX=$rcfgbase->{notif_mx}->[0];
my $FROM=$rcfgbase->{notif_from}->[0];
my $FROM_NAME=$rcfgbase->{notif_from_name}->[0];
my $SUBJECT=$rcfgbase->{notif_subject}->[0];
my $SERIAL_PORT=$rcfgbase->{notif_serial_port}->[0];
my $PIN=$rcfgbase->{notif_pin}->[0];

my $db_server=$rcfgbase->{db_server}->[0];
my $db_name=$rcfgbase->{db_name}->[0];
my $db_user=$rcfgbase->{db_user}->[0];
my $db_pwd=$rcfgbase->{db_pwd}->[0];

#while (my ($k,$v)=each %$rcfgbase) {print "$k ";foreach (@$v) {print "$_ ";} print "\n";}
#exit;
#-------------------------------------------------------------------------------------------
#my %opts=();
#getopts("l:t:d:h",\%opts);
#my $log_level= (defined $opts{d}) ? $opts{d} : 'info';
##my $LAPSE = (defined $opts{l}) ? $opts{l} : $rcfgbase->{notif_lapse}->[0];
#my $LAPSE = (defined $opts{l}) ? $opts{l} : '60';
#my $TYPE = (defined $opts{t}) ? lc $opts{t} : 'all';
#if ($opts{h}) { my $USAGE=usage(); die "$USAGE\n"; }

#-------------------------------------------------------------------------------------------
my $store=Crawler::Store->new(db_server=>$db_server,db_name=>$db_name,db_user=>$db_user,db_pwd=>$db_pwd, log_level=>'debug');
$store->store_path($STORE_PATH);
my $dbh=$store->open_db();

#-------------------------------------------------------------------------------------------
my $notif = Crawler::Notifications->new('log_level' => 'debug');
$notif->store($store);
$notif->dbh($dbh);

#my $notif_alerts_set=$store->get_notif_alerts_set($dbh);

my $txt = $notif->compose_notification_body($set_clr,$url,\@ALERT,{'template'=>$TEMPLATE});

print "$txt\n";

#   my $txt = $DEFAULT_BODY;
#   if ($notif_info->{'template'} ne '') { $txt = $notif_info->{'template'}; }
#
#   my $id_dev_alert=$a->[aDEVICE];    #id del device
#   my $device=$a->[aALERT_DEV_NAME].'.'.$a->[aALERT_DEV_DOMAIN];
#   my $ip=$a->[aALERT_DEV_IP];
#   my $alert_cause=$a->[aALERT_CAUSE]; # alert cause
#   my $id_alert=$a->[aID_ALERT];       # id de la alerta
#   my $event_data=$a->[aEVENT_DATA] || '';   # Datos del evento
#   if ($event_data ne '') { $event_data=~s/ \| /\n/g; }
#   my $ack = $a->[aACK];               # ack
#   my $id_ticket = $a->[aID_TICKET];   # id ticket
#   my $severity = $a->[aSEVERITY];     # severity
#   my $date_str = $self->time2date($a->[aDATE]);   # alert date
#   my $id_metric = $a->[aID_METRIC];   # id de la metrica
#   my $alert_type = $a->[aALERT_TYPE]; # alert type
#   my $notif = $a->[aNOTIF];           # notif flag
#   my $mname = $a->[aMNAME];           # metric name
#   my $watch = $a->[aWATCH];           # watch
#   my $type = $a->[aTYPE];             # type
#   my $counter = $a->[aCOUNTER];       # alert counter
#
#   # ------------------------------------------------------------
#   $txt =~s/__SET_CLR_ALERT__/$set_clr/;
#   $txt =~s/__ALERT_CAUSE__/$alert_cause/;
#   $txt =~s/__DEVICE__/$device/;
#   $txt =~s/__IP__/$ip/;
#   # OJO!! El evento puede tener caracteres html que no sean parseables por Telegram (ej. <br>)
#   # Hay que valorar si para este caso $event_data=''
#   $txt =~s/__EVENT_DATA__/$event_data/;
#                                                                                  
