#####################################################################################################
# Fichero: (Metrics::Cisco.pm)   $Id: Cisco.pm,v 1.2 2004/10/04 10:29:53 fml Exp $
# Descripcion: Metrics::Cisco.pm
# Set Tab=3
#####################################################################################################
package Metrics::Cisco;
$VERSION='1.00';
use strict;
use Crawler::SNMP;


#----------------------------------------------------------------------------
# metrica: cisco_buffer_errors
#----------------------------------------------------------------------------
#sql INSERT INTO cfg_monitor_snmp (subtype,class,lapse,descr,items,oid,get_iid,oidn,oid_info) values ('cisco_buffers_errors', 'CISCO', 300, 'ERRORES EN BUFFERS DE MEMORIA', 'Buffer Failures|No Free Memory', '.1.3.6.1.4.1.9.2.1.46.0|.1.3.6.1.4.1.9.2.1.47.0', '','bufferFail.0|bufferNoMem.0','OLD-CISCO-SYS-MIB|bufferFail.0|INTEGER|Count of the number of buffer allocation failures.<br>OLD-CISCO-SYS-MIB|bufferNoMem.0|INTEGER|Count of the number of buffer create failures due to no free memory.');

#----------------------------------------------------------------------------
sub cisco_buffer_errors {
my ($device,$rcfg,$subtype)=@_;

   #---------------------------------------------------------------
   @Metrics::Base::OIDs=qw( .1.3.6.1.4.1.9.2.1.46.0|.1.3.6.1.4.1.9.2.1.47.0 );
   $Metrics::Base::METRIC{label}='Errores en los buffers de memoria';
   $Metrics::Base::METRIC{mtype}='STD_BASE';
   $Metrics::Base::METRIC{vlabel}='Num';
   $Metrics::Base::METRIC{module}='mod_snmp_get';
   $Metrics::Base::METRIC{values}='Buffer Failures|No Free Memory';
   $Metrics::Base::METRIC{mode}='GAUGE';
   $Metrics::Base::METRIC{top_value}=1;
   #---------------------------------------------------------------
   my $m=&Metrics::Base::m2txml_snmp_simple($device,$rcfg,$subtype);
   return $m;
}


#----------------------------------------------------------------------------
# metrica: cisco_buffer_usage
#----------------------------------------------------------------------------

#----------------------------------------------------------------------------
sub cisco_buffer_usage {
my ($device,$rcfg,$subtype)=@_;

   #---------------------------------------------------------------
   @Metrics::Base::OIDs=qw( .1.3.6.1.4.1.9.2.1.15.0|.1.3.6.1.4.1.9.2.1.23.0|.1.3.6.1.4.1.9.2.1.31.0|.1.3.6.1.4.1.9.2.1.39.0|.1.3.6.1.4.1.9.2.1.63.0 );
   $Metrics::Base::METRIC{label}='Numero total de buffers';
   $Metrics::Base::METRIC{mtype}='STD_BASE';
   $Metrics::Base::METRIC{vlabel}='Num';
   $Metrics::Base::METRIC{module}='mod_snmp_get';
   $Metrics::Base::METRIC{values}='bufferSmallTotal|bufferMiddleTotal|bufferBigTotal|bufferLargeTotal|bufferHugeTotal';
   $Metrics::Base::METRIC{mode}='GAUGE';
   $Metrics::Base::METRIC{top_value}=1;
   #---------------------------------------------------------------
   my $m=&Metrics::Base::m2txml_snmp_simple($device,$rcfg,$subtype);
   return $m;
}


#----------------------------------------------------------------------------
# metrica: cisco_cpu
#----------------------------------------------------------------------------

#----------------------------------------------------------------------------
sub cisco_cpu {
my ($device,$rcfg,$subtype)=@_;

   #---------------------------------------------------------------
   @Metrics::Base::OIDs=qw( .1.3.6.1.4.1.9.2.1.58.0 );
   $Metrics::Base::METRIC{label}='CPU';
   $Metrics::Base::METRIC{mtype}='STD_BASE';
   $Metrics::Base::METRIC{vlabel}='Procentaje';
   $Metrics::Base::METRIC{module}='mod_snmp_get';
   $Metrics::Base::METRIC{values}='Uso de CPU';
   $Metrics::Base::METRIC{mode}='GAUGE';
   $Metrics::Base::METRIC{top_value}=1;
   #---------------------------------------------------------------
   my $m=&Metrics::Base::m2txml_snmp_simple($device,$rcfg,$subtype);
   return $m;
}

#----------------------------------------------------------------------------
# metrica: cisco_ds0_errors
#----------------------------------------------------------------------------

#----------------------------------------------------------------------------
sub cisco_ds0_errors {
my ($device,$rcfg,$subtype)=@_;

   #---------------------------------------------------------------
   @Metrics::Base::OIDs=qw( .1.3.6.1.4.1.9.10.19.1.2.1.0|.1.3.6.1.4.1.9.10.19.1.2.5.0 );
   $Metrics::Base::METRIC{label}='Errores RDSI (DS0s)';
   $Metrics::Base::METRIC{mtype}='STD_BASE';
   $Metrics::Base::METRIC{vlabel}='Num';
   $Metrics::Base::METRIC{module}='mod_snmp_get';
   $Metrics::Base::METRIC{values}='Reject RDSI|Sin recursos RDSI';
   $Metrics::Base::METRIC{mode}='GAUGE';
   $Metrics::Base::METRIC{top_value}=1;
   #---------------------------------------------------------------
   my $m=&Metrics::Base::m2txml_snmp_simple($device,$rcfg,$subtype);
   return $m;
}

#----------------------------------------------------------------------------
# metrica: cisco_ds0_usage
#----------------------------------------------------------------------------

#----------------------------------------------------------------------------
sub cisco_ds0_usage {
my ($device,$rcfg,$subtype)=@_;

   #---------------------------------------------------------------
   @Metrics::Base::OIDs=qw( .1.3.6.1.4.1.9.10.19.1.1.4.0|.1.3.6.1.4.1.9.10.19.1.1.8.0 );
   $Metrics::Base::METRIC{label}='Ocupacion de circuitos RDSI';
   $Metrics::Base::METRIC{mtype}='STD_BASE';
   $Metrics::Base::METRIC{vlabel}='Num';
   $Metrics::Base::METRIC{module}='mod_snmp_get';
   $Metrics::Base::METRIC{values}='Ocupados RDSI (DS0s)|Maximo valor en DS0s';
   $Metrics::Base::METRIC{mode}='GAUGE';
   $Metrics::Base::METRIC{top_value}=1;
   #---------------------------------------------------------------
   my $m=&Metrics::Base::m2txml_snmp_simple($device,$rcfg,$subtype);
   return $m;
}


#----------------------------------------------------------------------------
# metrica: cisco_memory
#----------------------------------------------------------------------------

#----------------------------------------------------------------------------
sub cisco_memory {
my ($device,$rcfg,$subtype)=@_;

   #---------------------------------------------------------------
   @Metrics::Base::OIDs=qw( .1.3.6.1.4.1.9.9.48.1.1.1.5.1 .1.3.6.1.4.1.9.9.48.1.1.1.6.1 .1.3.6.1.4.1.9.9.48.1.1.1.5.2 .1.3.6.1.4.1.9.9.48.1.1.1.6.2 );
   $Metrics::Base::METRIC{label}='Memoria';
   $Metrics::Base::METRIC{mtype}='STD_BASE';
   $Metrics::Base::METRIC{vlabel}='bytes';
   $Metrics::Base::METRIC{module}='mod_snmp_get';
   $Metrics::Base::METRIC{values}='Bytes usados (Processor)|Bytes libres (Processor)|Bytes usados (I/O)|Bytes libres (I/O)';
   $Metrics::Base::METRIC{mode}='GAUGE';
   $Metrics::Base::METRIC{top_value}=1;
   #---------------------------------------------------------------
   my $m=&Metrics::Base::m2txml_snmp_simple($device,$rcfg,$subtype);
   return $m;
}

#----------------------------------------------------------------------------
# metrica: cisco_modem_errors
#----------------------------------------------------------------------------

#----------------------------------------------------------------------------
sub cisco_modem_errors {
my ($device,$rcfg,$subtype)=@_;

   #---------------------------------------------------------------
   @Metrics::Base::OIDs=qw( .1.3.6.1.4.1.9.10.19.1.2.2.0|.1.3.6.1.4.1.9.10.19.1.2.6.0 );
   $Metrics::Base::METRIC{label}='Errores en Modems';
   $Metrics::Base::METRIC{mtype}='STD_BASE';
   $Metrics::Base::METRIC{vlabel}='Num';
   $Metrics::Base::METRIC{module}='mod_snmp_get';
   $Metrics::Base::METRIC{values}='Reject en modem|Sin recursos de modem';
   $Metrics::Base::METRIC{mode}='GAUGE';
   $Metrics::Base::METRIC{top_value}=1;
   #---------------------------------------------------------------
   my $m=&Metrics::Base::m2txml_snmp_simple($device,$rcfg,$subtype);
   return $m;
}


#----------------------------------------------------------------------------
# metrica: cisco_modem_usage
#----------------------------------------------------------------------------

#----------------------------------------------------------------------------
sub cisco_modem_usage {
my ($device,$rcfg,$subtype)=@_;

   #---------------------------------------------------------------
   @Metrics::Base::OIDs=qw( .1.3.6.1.4.1.9.10.19.1.1.2.0|.1.3.6.1.4.1.9.9.47.1.1.7.0 );
   $Metrics::Base::METRIC{label}='Ocupacion de Modems';
   $Metrics::Base::METRIC{mtype}='STD_BASE';
   $Metrics::Base::METRIC{vlabel}='Num';
   $Metrics::Base::METRIC{module}='mod_snmp_get';
   $Metrics::Base::METRIC{values}='Modems ocupados|Modems disponibles';
   $Metrics::Base::METRIC{mode}='GAUGE';
   $Metrics::Base::METRIC{top_value}=1;
   #---------------------------------------------------------------
   my $m=&Metrics::Base::m2txml_snmp_simple($device,$rcfg,$subtype);
   return $m;
}


#----------------------------------------------------------------------------
#cDot11ActiveWirelessClients OBJECT-TYPE
#        SYNTAX     Gauge32 (0..2007)
#        UNITS      "Device"
#        MAX-ACCESS read-only
#        STATUS     current
#        DESCRIPTION
#                "This is the number of wireless clients
#                currently associating with this device on this
#                interface."
#        ::= { cDot11ActiveDevicesEntry 1 }
#
#----------------------------------------------------------------------------
#----------------------------------------------------------------------------
# metrica: cisco_wap_users
#----------------------------------------------------------------------------
#sql INSERT INTO cfg_monitor_snmp (subtype,class,lapse,descr,items,oid,get_iid,oidn,oid_info)  VALUES  ('cisco_wap_users', 'CISCO', 300, 'USUARIOS ACTIVOS EN ACCESS POINT', 'Usuarios','1.3.6.1.4.1.9.9.273.1.1.2.1.1.1','','CISCO-DOT11-ASSOCIATION-MIB::cDot11ActiveWirelessClients.1','Muestra el numero de clientes wireless asociados con el dispositivo')  ON DUPLICATE KEY UPDATE  subtype='cisco_wap_users',   class='CISCO',   lapse=300,  descr='USUARIOS ACTIVOS EN ACCESS POINT',  items='Usuarios',   oid='1.3.6.1.4.1.9.9.273.1.1.2.1.1.1',   get_iid='',   oidn='CISCO-DOT11-ASSOCIATION-MIB::cDot11ActiveWirelessClients.1',   oid_info='CISCO-DOT11-ASSOCIATION-MIB|cDot11ActiveWirelessClients.1|GAUGE32|Muestra el numero de clientes wireless asociados con el dispositivo';
#sql INSERT INTO cfg_assigned_metrics (range,id_type,include,lapse,type,subtype,active_iids) VALUES ('.1.3.6.1.4.1.9.1.525','oid',1,300,'snmp','cisco_wap_users','all') ON DUPLICATE KEY UPDATE  range='.1.3.6.1.4.1.9.1.525',  id_type='oid',  include=1,  lapse=300,  type='snmp',  subtype='cisco_wap_users',  active_iids='all'"
#----------------------------------------------------------------------------
sub cisco_wap_users {
my ($device,$rcfg,$subtype)=@_;

   #---------------------------------------------------------------
   @Metrics::Base::OIDs=qw( 1.3.6.1.4.1.9.9.273.1.1.2.1.1.1 );
   $Metrics::Base::METRIC{label}='Numero de clientes wireless';
   $Metrics::Base::METRIC{mtype}='STD_BASE';
   $Metrics::Base::METRIC{vlabel}='Num';
   $Metrics::Base::METRIC{module}='mod_snmp_get';
   $Metrics::Base::METRIC{values}='Usuarios';
   $Metrics::Base::METRIC{mode}='GAUGE';
   $Metrics::Base::METRIC{top_value}=1;
   #---------------------------------------------------------------
   my $m=&Metrics::Base::m2txml_snmp_simple($device,$rcfg,$subtype);
   return $m;
}


1;
__END__
