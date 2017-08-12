#####################################################################################################
# Fichero: (Crawler::Device.pm) $Id: Device.pm,v 1.1 2004/10/04 10:43:18 fml Exp $ 
# Fecha: 15/08/2001
# Revision: Ver $VERSION
# Descripción: Clase Crawler::Device
# Set Tab=3
#####################################################################################################
use Crawler;
package Crawler::Device;
@ISA=qw(Crawler);
$VERSION='1.00';
use strict;
use File::Copy;
use Crawler::SNMP;

#----------------------------------------------------------------------------
# Funcion: Constructor
# Descripcion: Crea un objeto del tipo Crawler::Device
#----------------------------------------------------------------------------
sub new {
my ($class,%arg) =@_;
	
   my $self=$class->SUPER::new(%arg);
   $self->{_cfg} = $arg{cfg} || '';
   $self->{_file_txml} = $arg{file_txml} || '';
   $self->{_txml} = $arg{txml} || '';
   $self->{_file_dev} = $arg{file_dev} || '';
   $self->{_devices} = $arg{devices} || [];
   $self->{_ip} = $arg{ip} || '';
   $self->{_type} = $arg{type} || '';
   $self->{_name} = $arg{name} || '';
   $self->{_oid} = $arg{oid} || '';
   $self->{_dns} = $arg{dns} || undef;
   $self->{_rule_ip} = $arg{rule_ip} || '';
   $self->{_rule_name} = $arg{rule_name} || '';
   $self->{_comunity} = $arg{comunity} || 'public';
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
   else {
      return $self->{_cfg};

   }
}

#----------------------------------------------------------------------------
# file_txml 
#----------------------------------------------------------------------------
sub file_txml {
my ($self,$file_txml) = @_;
   if (defined $file_txml) {
      $self->{_file_txml}=$file_txml;
   }
   else {
      return $self->{_file_txml};

   }
}


#----------------------------------------------------------------------------
# devices
#----------------------------------------------------------------------------
sub devices {
my ($self,$devices) = @_;
   if (defined $devices) {
      $self->{_devices}=$devices;
   }
   else {
      return $self->{_devices};

   }
}


#----------------------------------------------------------------------------
# file_dev
#----------------------------------------------------------------------------
sub file_dev {
my ($self,$file_dev) = @_;
   if (defined $file_dev) {
      $self->{_file_dev}=$file_dev;
   }
   else {
      return $self->{_file_dev};

   }
}


#----------------------------------------------------------------------------
# txml
#----------------------------------------------------------------------------
sub txml {
my ($self,$txml) = @_;
   if (defined $txml) {
      $self->{_txml}=$txml;
   }
   else {
      return $self->{_txml};

   }
}

#----------------------------------------------------------------------------
# ip 
#----------------------------------------------------------------------------
sub ip {
my ($self,$ip) = @_;
   if (defined $ip) {
      $self->{_ip}=$ip;
   }
   else {
      return $self->{_ip};

   }
}

#----------------------------------------------------------------------------
# name
#----------------------------------------------------------------------------
sub name {
my ($self,$name) = @_;
   if (defined $name) {
      $self->{_name}=$name;
   }
   else {
      return $self->{_name};

   }
}

#----------------------------------------------------------------------------
# type
#----------------------------------------------------------------------------
sub type {
my ($self,$type) = @_;
   if (defined $type) {
      $self->{_type}=$type;
   }
   else {
      return $self->{_type};

   }
}


#----------------------------------------------------------------------------
# oid
#----------------------------------------------------------------------------
sub oid {
my ($self,$oid) = @_;
   if (defined $oid) {
      $self->{_oid}=$oid;
   }
   else {
      return $self->{_oid};

   }
}

#----------------------------------------------------------------------------
# dns
#----------------------------------------------------------------------------
sub dns {
my ($self,$dns) = @_;
my $resolver_file='/etc/resolv.conf';

   if (defined $dns) {
      $self->{_dns}=$dns;
   }
   else {
		if (defined $self->{_dns}) { return $self->{_dns}; }
		else {
			open (F,"<$resolver_file");
			while (<F>) {
				chomp;
				if (/nameserver\s+(\d+\.\d+\.\d+\.\d+)/) {
					$self->{_dns}=$1;
					last;
				}
			}
			close F;
      	return $self->{_dns};
		}
   }
}

#----------------------------------------------------------------------------
# rule_ip 
#----------------------------------------------------------------------------
sub rule_ip {
my ($self,$rule_ip) = @_;
   if (defined $rule_ip) {
      $self->{_rule_ip}=$rule_ip;
   }
   else {
      return $self->{_rule_ip};
   }
}

#----------------------------------------------------------------------------
# rule_name
#----------------------------------------------------------------------------
sub rule_name {
my ($self,$rule_name) = @_;
   if (defined $rule_name) {
      $self->{_rule_name}=$rule_name;
   }
   else {
      return $self->{_rule_name};
   }
}

#----------------------------------------------------------------------------
# comunity 
#----------------------------------------------------------------------------
sub comunity {
my ($self,$comunity) = @_;
   if (defined $comunity) {
      $self->{_comunity}=$comunity;
   }
   else {
      return $self->{_comunity};
   }
}

#----------------------------------------------------------------------------
# Funcion: device_nok
# Descripcion:
# Comprueba si el dispositivo cumple la regla especificada
#----------------------------------------------------------------------------
sub device_nok {
my ($self,$device,$rule)=@_;

   if ($device =~ /$rule/) {return 0;}
   return 1;

}


#----------------------------------------------------------------------------
# Funcion: get_devices
# Descripcion: Obtiene el vector con los dispositivos especificados. 
# Si la fuente de datos es un fichero hace ciertas validaciones.
# Si $query=1 realiza querys snmp al dispositivo
# nombre,ip
# out: vector con name,domain,ip,type,sysoid,sysloc,sysdesc,community,version
#----------------------------------------------------------------------------
sub get_devices  {
my ($self,$query)=@_;
my @devices=();
my $dev=undef;

	my $file=$self->file_dev();

	my $ip=$self->ip();
	my $name=$self->name();
	my $type=$self->type();
	my $oid=$self->oid();

	my $rule_ip=$self->rule_ip();
	my $rule_name=$self->rule_name();

	if (-e $file) { $dev=$self->parse_csv($file); }
	elsif ($ip || $name) { push @$dev,[ $name,$ip,$type,$oid ]; }
	else {
		$self->log('debug',"get_devices::[WARN] No definido file ni ip/name");
      return;
   }

	foreach (@$dev) {

		my %data=();
      my $N=$_->[0];
      my $IP=$_->[1];
      my $TYPE=$_->[2];
      my $OID=$_->[3];

		if ($IP) {
			if ($IP !~ /(\d+)\.(\d+)\.(\d+)\.(\d+)/) {
				$self->log('debug',"get_devices::[WARN] $IP no tiene formato correcto");
         	next;
			}

			if (($rule_ip) && ($self->device_nok($IP,$rule_ip)) ) {next;}

			$data{ip}=$IP;
			if ($N) {
				#Una posibilidad es contrastar con DNS y advertir al usuario
				#pero a lo mejor quiere que el nombre sea distinto ???

				if (($rule_name) && ($self->device_nok($N,$rule_name)) ) {next;}

				if ($N =~ /(\d+)\.(\d+)\.(\d+)\.(\d+)/) { $data{name}=$N; $data{domain}=''; }
	         elsif ($N=~/^(.*?)\.(.*)$/) { $data{name}=$1; $data{domain}=$2; }
				else { $data{name}=$N; $data{domain}=''; }
			}
			else { 
				$N=$self->get_name_from_ip($IP); 
				if (!defined $N) { $data{name}=$IP; $data{domain}=''; }
				else {
	            if ($N=~/^(.*?)\.(.*)$/) { $data{name}=$1; $data{domain}=$2; }
	            else { $data{name}=$N; $data{domain}=''; }
				}
			} 
		}

		elsif ($N) { 
			if (($rule_name) && ($self->device_nok($N,$rule_name)) ) {next;}

			$IP=$self->get_ip_from_name($IP); 
			if (! $IP) { 
            $self->log('debug',"get_devices::[WARN] No se encuentra la IP de $N");
            next;
         }

			if (($rule_ip) && ($self->device_nok($IP,$rule_ip)) ) {next;}

			$data{ip}=$IP;
         if ($N=~/^(.*?)\.(.*)$/) { $data{name}=$1; $data{domain}=$2; }
         else { $data{name}=$N; $data{domain}=''; }
		}

		else {
			$self->log('debug',"get_devices::[WARN] No definido ip/name");
			next;
		}

		#---------------------------------------------------------------
		# Busco OID
		if ($query) {
			$data{community}=$self->comunity();
			$data{type}=$TYPE;

	      #---------------------------------------------------------------
   	   # Busco version SNMP
      	my $snmp=Crawler::SNMP->new();
      	$data{version}=$snmp->snmp_get_version($data{ip},$data{community});
			if ($data{version}) { 

				if (! $OID) {
					$data{sysoid}=$snmp->snmp_get_oid($data{ip},$data{community},$data{version});
				}
				else {$data{sysoid}=$OID;}

      		$data{sysloc}=$snmp->snmp_get_location($data{ip},$data{community},$data{version});
      		$data{sysdesc}=$snmp->snmp_get_description($data{ip},$data{community},$data{version});
			}
		}

		push @devices, \%data;
	}

	$self->devices(\@devices);
	return \@devices;
}


#----------------------------------------------------------------------------
# Funcion: get_name_from_ip
# Descripcion:
# in: ip
# out: name | undef
#----------------------------------------------------------------------------
sub get_name_from_ip  {
my ($self,$ip)=@_;
my $name=undef;

	#Busco nombre del DNS
	my $dns=$self->dns();
	if (defined $dns) {
		$name=$self->dns_query($dns,$ip);
		if (defined $name) {return $name;}
	}

   #Busco nombre del sysname
	my $comunity=$self->comunity();
   my $snmp=Crawler::SNMP->new();
	if (defined $snmp) {
		$name=$snmp->snmp_get_name($ip,$comunity);
		if ((!defined $name) || ($name eq 'U')) { return undef; }
		else {return $name;}
	}

	return undef;

}

#----------------------------------------------------------------------------
# Funcion: get_ip_from_name
# Descripcion:
# in: name
# out: ip | undef
#----------------------------------------------------------------------------
sub get_ip_from_name  {
my ($self,$ip)=@_;
my $name=undef;

   #Busco ip del DNS
   my $dns=$self->dns();
   if (defined $dns) {
      $name=$self->dns_query($dns,$ip);
      if (defined $name) {return $name;}
   }
   return undef;
}

#-----------------------------------------------------------------------
sub dns_query {
my ($self,$dns, $val)=@_;
my $class;
my $r=undef;

use Net::DNS;

	my $res = new Net::DNS::Resolver;
	if (! defined $res) {
		$self->log('warning',"dns_query::[WARN] al crear objeto resolver ");
		return $r;
	}

   if ($val=~/^(\d+).(\d+).(\d+).(\d+)/) {$class='PTR';}
   else {$class='A';}
   #print "CLASE=$class\n";
   $res->nameservers($dns);
   my $query = $res->search($val);
   if ($query) {
      foreach my $rr ($query->answer) {
         next unless $rr->type eq $class;
         $r = ($class eq 'PTR') ? $rr->ptrdname : $rr->address;
      }
   }
	else { $self->log('warning',"dns_query::[WARN] ($dns) @{[$res->errorstring]} ");  }
	
   return ($r);
}



#----------------------------------------------------------------------
sub parse_csv {
my ($self,$file)=@_;

   my @data=();
   open (F,"<$file");
   while (<F>) {
      chomp;
      if (/^#/) {next;}
      push @data,[ split(',',$_) ];
   }
   close F;
   return \@data;
}


1;
__END__

