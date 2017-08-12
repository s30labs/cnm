#----------------------------------------------------------------------------
use Crawler;
package Crawler::CNMEvents;
@ISA=qw(Crawler);
$VERSION='1.00';
#----------------------------------------------------------------------------
use strict;
#use JSON;
use Data::Dumper;
use ONMConfig;
use Digest::MD5 qw(md5_hex);

#----------------------------------------------------------------------------
my $FILE_CONF='/cfg/onm.conf';
#----------------------------------------------------------------------------

%Crawler::CNMEvents::cnmEvCodes = (

	'cnmEvNoLinkSet' => 1,
	'cnmEvIFDownfSet' => 2,

);

#----------------------------------------------------------------------------
# Funcion: Constructor
# Descripcion: Crea un objeto del tipo Crawler::CNMEvents
#----------------------------------------------------------------------------
sub new {
my ($class,%arg) =@_;

   my $self=$class->SUPER::new(%arg);
   $self->{_ip} = $arg{ip} || my_ip();
   $self->{_snmp} = $arg{snmp} || undef;
   return $self;
}

#----------------------------------------------------------------------------
# ip
#----------------------------------------------------------------------------
sub ip {
my ($self,$ip) = @_;
   if (defined $ip) {
      $self->{_ip}=$ip;
   }
   else { return $self->{_ip}; }
}

#----------------------------------------------------------------------------
# snmp
#----------------------------------------------------------------------------
sub snmp {
my ($self,$snmp) = @_;
   if (defined $snmp) {
      $self->{_snmp}=$snmp;
   }
   else { return $self->{_snmp}; }
}

#----------------------------------------------------------------------------
# cnmEvNoLinkSet
#----------------------------------------------------------------------------
# Genera el trap que indica que no hay link en el interfaz de red del appliance.
# cnmTrapNoLinkSet
# cnmNotifNoLinkfSet
#----------------------------------------------------------------------------
sub cnmEvNoLinkSet  {
my ($self,$params)=@_;

	my $if = $params->{'if'};
	my $ip = $self->ip();
   my $cnmTrapMsg="No hay link en interfaz $if";
	my $cnmEvCode = (exists $Crawler::CNMEvents::cnmEvCodes{'cnmEvNoLinkSet'}) ? 
				$Crawler::CNMEvents::cnmEvCodes{'cnmEvNoLinkSet'} : 0  ;


	my $snmp = $self->{'snmp'};
	if (!defined $snmp) {
		my $store = $self->store();
		$snmp = Crawler::SNMP->new( store=>$store );
		$self->snmp($snmp);
	}
	my $version = (exists $params->{'version'}) ? $params->{'version'} : 2;

	my $uptime = $self->_get_uptime();

	if ($version==2) {

#cnmNotifNoLinkfSet NOTIFICATION-TYPE
#    VARIABLES   { cnmNotifCode, cnmNotifMsg }
#    DESCRIPTION
#            "Este trap se genera cuando se detecta que no hay link en el interfaz Ethernet"
#    ::= { cnmNotifBase 100 }

	   my $x = md5_hex("cnmNotifNoLinkSet $if");
   	my $trap_key = substr $x,0,10;

   	my $r=$snmp->core_snmp_trap_ext(

         {'comunity'=>'public', 'version'=>2, 'host_ip'=>$ip, 'agent'=>$ip },
         {'enterprise'=>'CNM-NOTIFICATIONS-MIB::cnmNotifNoLinkSet', 'uptime'=>$uptime,
            'vardata'=> [  [ 'cnmNotifCode', 1, $cnmEvCode ],
                           [ 'cnmNotifMsg', 1, $cnmTrapMsg ],
                           [ 'cnmNotifKey', 1, $trap_key ]  ]
         }
   	);
	}
	else {
#cnmTrapNoLinkSet TRAP-TYPE
#    ENTERPRISE  cnmTrapsBase
#    VARIABLES   { cnmTrapCode, cnmTrapMsg }
#    DESCRIPTION
#           "Este trap se genera cuando se detecta que no hay link en el interfaz Ethernet"
#    ::= 100
#
  		my $specific=100;
  		my $r=$snmp->core_snmp_trap_ext(
			
         {'comunity'=>'public', 'version'=>1, 'host_ip'=>$ip, 'agent'=>$ip },
         {'enterprise'=>'cnmTrapsBase', 'specific'=>$specific, 'uptime'=>$uptime,
           'vardata'=> [  [ 'cnmTrapCode', 1, $cnmEvCode ],
                          [ 'cnmTrapMsg', 2, $cnmTrapMsg ]  ]
         }
  		);
	}

}


#----------------------------------------------------------------------------
# cnmEvIFDownfSet
#----------------------------------------------------------------------------
# Genera el trap que indica que el interfaz del appliance esta caido.
# cnmNotiIFDownfSet
#----------------------------------------------------------------------------
sub cnmEvIFDownfSet  {
my ($self,$params)=@_;


   my $if = $params->{'if'};
	my $ip = $self->ip();
   my $cnmTrapMsg="El interfaz $if esta caido";
   my $cnmEvCode = (exists $Crawler::CNMEvents::cnmEvCodes{'cnmEvNoLinkSet'}) ?
            $Crawler::CNMEvents::cnmEvCodes{'cnmEvNoLinkSet'} : 0  ;


   my $snmp = $self->{'snmp'};
   if (!defined $snmp) {
      my $store = $self->store();
      $snmp = Crawler::SNMP->new( store=>$store );
      $self->snmp($snmp);
   }

   my $version = (exists $params->{'version'}) ? $params->{'version'} : 2;

   if ($version==2) {

#cnmNotiIFDownfSet NOTIFICATION-TYPE
#    VARIABLES   { cnmNotifCode, cnmNotifMsg }
#    DESCRIPTION
#            "Este trap se genera cuando se detecta que el interfaz Ethernet de trabajo esta caido o deshabilitado desde el sistema operativo del CNM"
#    ::= { cnmNotifBase 102 }

	   my $x = md5_hex("cnmNotiIFDownfSet $if");
   	my $trap_key = substr $x,0,10;


   	my $r=$snmp->core_snmp_trap_ext(

         {'comunity'=>'public', 'version'=>2, 'host_ip'=>$ip, 'agent'=>$ip },
         {'enterprise'=>'CNM-NOTIFICATIONS-MIB::cnmNotiIFDownfSet', 'uptime'=>$uptime,
            'vardata'=> [  [ 'cnmTrapCode', 1, $cnmEvCode ],
                           [ 'cnmTrapMsg', 2, $cnmTrapMsg ],
                           [ 'cnmNotifKey', 1, $trap_key ]  ]
         }
   	);

	}
}



#----------------------------------------------------------------------------
sub _get_uptime  {
my ($self)=@_;

	my $values = `cat /proc/uptime`;
	chomp $values;
	my ($secs,$idle) = split (/\s+/,$values);
	return $secs;
}

1;
