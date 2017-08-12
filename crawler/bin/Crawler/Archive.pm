#####################################################################################################
# Fichero: (Crawler::Archive.pm) $Id: Archive.pm,v 1.3 2004/05/02 15:36:14 fml Exp $ 
# Fecha: 15/08/2001
# Revision: Ver $VERSION
# Descripción: Clase Crawler::Archive
# Set Tab=3
#####################################################################################################
use Crawler;
package Crawler::Archive;
@ISA=qw(Crawler);
$VERSION='1.00';
use strict;
use File::Copy;
use Crawler::SNMP;


#----------------------------------------------------------------------------
my $DEFAULT_DOMAIN='cm.es';

#----------------------------------------------------------------------------
# Funcion: Constructor
# Descripcion: Crea un objeto del tipo Crawler::Archive
#----------------------------------------------------------------------------
sub new {
my ($class,%arg) =@_;
	
   my $self=$class->SUPER::new(%arg);
   $self->{_cfg} = $arg{cfg} || '';
   $self->{_file_txml} = $arg{file_txml} || '';
   $self->{_txml} = $arg{txml} || '';
   $self->{_file_dev} = $arg{file_dev} || '';
   $self->{_devices} = $arg{devices} || [];
   $self->{_universe} = $arg{universe} || '';
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
# universe 
#----------------------------------------------------------------------------
sub universe {
my ($self,$universe) = @_;
   if (defined $universe) {
      $self->{_universe}=$universe;
   }
   else {
      return $self->{_universe};

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
# Descripcion:
# nombre,ip
#----------------------------------------------------------------------------
sub get_devices  {
my $self=shift;
my @devices=();
my @vector=();


	my $file=$self->file_dev();
	my $rule_ip=$self->rule_ip();
	my $rule_name=$self->rule_name();

	####
	# $file no tiene porque ser un fichero de dispositivos, puede ser cada linea del mismo.
	####
	if ($file =~ /\((.*?\,\d+\.\d+\.\d+\.\d+.*)\)/) { push @vector,$1; }
	else {
		if (! -e $file) { 
			$self->log('debug',"get_devices::[WARN] No existe $file");
			return; 
		}

		open (F,"<$file");
		while (<F>) {
   		chomp;
			push @vector,$_;
		}
	   close F;
	}
   
	foreach (@vector) {
      my ($v1,$v2,$v3,$v4,$v5)=split(/\,/,$_);
      my %data=();
     # my $ip=undef;
		$data{domain}=$DEFAULT_DOMAIN;
      if ((defined $v2) && ($v2=~/(\d+)\.(\d+)\.(\d+)\.(\d+)/)) { $data{ip}=$v2;  }
      if ((defined $v1) && ($v1 !~/(\d+)\.(\d+)\.(\d+)\.(\d+)/)) {
			$data{name}=$v1;
			if ($data{name}=~/^(.*?)\.(.*)$/) {
         	$data{name}=$1;
            $data{domain}=$2;
         }
         else { $data{domain}=''; }
		}
      else {
      	$data{name}=$v1;
         $data{ip}=$v1;
      }

		$data{txml}=$v3;		
		$data{type}=$v4;		
		$data{app}=$v5;		

		if (($rule_ip) && ($self->device_nok($data{ip},$rule_ip)) ) {next;}
		if (($rule_name) && ($self->device_nok($data{name},$rule_name)) ) {next;}

      push @devices,\%data;
   }

	$self->devices(\@devices);

}


#----------------------------------------------------------------------------
# Funcion: get_devices_ext
# Descripcion:
# nombre,ip
#----------------------------------------------------------------------------
sub get_devices_ext  {
my $self=shift;
my @devices_ext=();



   my $data=$self->devices();
	my $comunity=$self->comunity();
	my $snmp=Crawler::SNMP->new();
   foreach (@$data) {

      if ((! defined $_->{ip}) ||  (! defined $_->{name})) {next;}

		my $loc=$snmp->snmp_get_location($_->{ip},$comunity);
		my $desc=$snmp->snmp_get_description($_->{ip},$comunity);
		my $oid=$snmp->snmp_get_oid($_->{ip},$comunity);

#$self->log('debug',"*******::$loc ($loc[0])");


		if (defined $loc) {$_->{sysloc}=$loc;}
		if (defined $desc) {$_->{sysdesc}=$desc;}
		if (defined $oid) {$_->{sysoid}=$oid;}

      push @devices_ext,$_;
   }

	$self->devices(\@devices_ext);
}


#----------------------------------------------------------------------------
# Funcion: create_xml
# Descripcion:
#----------------------------------------------------------------------------
sub create_xml  {
my ($self,$mode)=@_;
my $txml=undef;

	if ($mode =~ /\<(\w+)\>/) {
		my $first="<$1>\n";
		my $last="</$1>\n";
		my $file_xml=$self->file_xml();
		if (open (F,"<$file_xml")) {
			local $/=undef;
      	my $new_xml=$first.<F>.$last;
      	close F;
      	
      	open (F,">$file_xml");
			print F $new_xml;
			close F;
   	}
   	else {$self->log('debug',"create_xml::[WARN] Al abrir $file_xml"); }
		return;
	}

	my $file_txml=$self->file_txml();

   if (! -e $file_txml) { 
		$self->log('debug',"create_xml::[WARN] No existe $file_txml");
		return; 
	}


   if (open (F,"<$file_txml")) {
		local $/=undef;
      $txml=<F>;
      close F;
		$txml=~s/^<universe1>(.*?)<\/universe1>$/$1/ms;
   }
   else {
		$self->log('debug',"create_xml::[WARN] Al abrir $file_txml");
		return;
	}

	$self->txml($txml);

	my $file_xml=$self->file_xml();
	my $data=$self->devices();
	my $universe=$self->universe();

	($mode eq '>') ? open (F,">$file_xml") : open (F,">>$file_xml");
   if ($universe) {print F "<$universe>\n";}
   foreach (@$data) {

  		if ((! defined $_->{ip}) ||  (! defined $_->{name}) || (! defined $_->{domain})) {next;}
      my $d=$txml;
		my $full_name=$_->{name}.'.'.$_->{domain};
      $d =~ s/__IP__/$_->{ip}/mg;
      $d =~ s/__NAME__/$full_name/mg;
      print F $d;
   }

   if ($universe) {print F "</$universe>\n";}
   close F;

}



#----------------------------------------------------------------------------
# Funcion: terminate_xml 
# Descripcion:
#----------------------------------------------------------------------------
sub terminate_xml  {
my ($self,$rfiles,$universe)=@_;
my $txml=undef;

	foreach my $file_xml (keys %$rfiles) {
		if ($universe =~ /\<(\w+)\>/) {
			my $first="<$1>\n";
			my $last="</$1>\n";
			if (open (F,"<$file_xml")) {
				local $/=undef;
      		my $new_xml=$first.<F>.$last;
      		close F;
      	
      		open (F,">$file_xml");
				print F $new_xml;
				close F;
   		}
   		else {$self->log('debug',"create_xml::[WARN] Al abrir $file_xml"); }
   	}
	}
	return;
}

#----------------------------------------------------------------------------
# Funcion: move_xml 
# Descripcion:
#----------------------------------------------------------------------------
sub move_xml  {
my ($self,$rfiles,$new_path)=@_;
my $txml=undef;

	my $cmd='';
	foreach my $file_xml (sort keys %$rfiles) {
		$file_xml=~/.*?\/([\w+|\.*]*)$/;
		my $file_dest=$new_path.$1;

		move ($file_xml,$file_dest);
		
		$cmd .= "/opt/crawler/bin/crawler -f $file_dest\n";
	}
	return $cmd;
}



1;
__END__

