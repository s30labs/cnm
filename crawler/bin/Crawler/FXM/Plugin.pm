#----------------------------------------------------------------------------
# Crawler::FXM::Plugin.pm
# Modulo para extender la clase FXM
# Extensiones para ACESA (STARIX)
#----------------------------------------------------------------------------
use Crawler::FXM;
package Crawler::FXM::Plugin;
@ISA=qw(Crawler::FXM);
$VERSION='1.00';
use strict;
use File::Basename;
use Data::Dumper;

#----------------------------------------------------------------------------
# Se cargan los modulos que haya en /opt/crawler/bin/Crawler/FXM/Plugin
#----------------------------------------------------------------------------
BEGIN { 
	unshift(@INC, '/opt/crawler/bin/Crawler/FXM');
#	my $path = '/opt/crawler/bin/Crawler/FXM/Plugin/*.pm';
#	my @files = < $path >;
#	foreach my $mod (@files){
#		my($filename, $directories, $suffix) = fileparse($mod);
#		require '/opt/crawler/bin/Crawler/FXM/Plugin/'.$filename;
#	}

   my $module='';
   my $path = '/opt/crawler/bin/Crawler/FXM/Plugin/*.pm';
   my @files = < $path >;
   foreach my $mod (@files){
      my($filename, $directories, $suffix) = fileparse($mod);
      my $m=$filename;
      $m=~s/(\S+)\.pm/$1/;
      $module='Crawler::FXM::Plugin::'.$m;
		eval("use $module");
		if ($@) { die "**ERROR** al cargar plugin $module ($@)\n"; }
      }
}

#use Crawler::FXM::Plugin::STARIX;

#----------------------------------------------------------------------------
# Funcion: Constructor
# Descripcion: Crea un objeto del tipo Crawler::FXM::Plugin
#----------------------------------------------------------------------------
sub new {
my ($class,%arg) =@_;

   my $self=$class->SUPER::new(%arg);
   $self->{_extra} = $arg{extra} || 0;
   return $self;
}

#----------------------------------------------------------------------------
# extra
#----------------------------------------------------------------------------
sub extra {
my ($self,$extra) = @_;
   if (defined $extra) {
      $self->{_extra}=$extra;
   }
   else { return $self->{_extra}; }
}

#----------------------------------------------------------------------------
# load_plugins
#----------------------------------------------------------------------------
sub load_plugins {
my ($self) = @_;

	my $module='';
   eval {
      my $path = '/opt/crawler/bin/Crawler/FXM/Plugin/*.pm';
      my @files = < $path >;
      foreach my $mod (@files){
         my($filename, $directories, $suffix) = fileparse($mod);
         require '/opt/crawler/bin/Crawler/FXM/Plugin/'.$filename;
         my $m=$filename;
         $m=~s/(\S+)\.pm/$1/;
         $module='Crawler::FXM::Plugin::'.$m;
         $module->import();
      }
   };
	if ($@) {
		$self->log('warning',"parse_fx:: [fx_PLUGIN] **WARN** ERROR AL CARGAR MODULO $module ($@)");
	}

}

#----------------------------------------------------------------------------
# fx_PLUGIN
# IN: $esp:       Vector con las funciones fx para generar los elementos de salida.
#     $values:    Vector con los datos de entrada (VECTOR O)
#     $desc:      Vector con los datos de la metrica (host_ip, mode, community ...)
# OUT:
#     $newals:    Vectorcon los vvalores de salida.
#
#----------------------------------------------------------------------------
sub fx_PLUGIN   {
my ($self,$esp,$values,$desc)=@_;

  	my ($custom_module,$data) = ('','');
   if ($esp->[0] =~ /^PLUGIN\((.*)\)$/) { ($custom_module,$data) = ($1,''); }
	elsif ($esp->[0] =~ /^PLUGIN\((.*)\)\((.*)\)$/) { ($custom_module,$data) = ($1,$2); }

	if ($custom_module eq '') { 
		$self->log('info',"parse_fx:: [fx_PLUGIN] **WARN** plugin_code NO DEFINIDA esp=@$esp values=@$values");
		return $values; 
	}

   # Hay que crear un objeto de la clase $custom_module
   # En dicha clase tiene que haber un constructor y una funcion plugin_code que implemente el plugin
   # Los parametros especificados sepasan a dicha funcion
	# Los modulos se pueden cargar al principio mediante una carga de todos los que
	# esten en el dir: /opt/crawler/bin/Crawler/FXM/Plugin
	my $newvalues=[];
	eval {
	   my $cx = 'Crawler::FXM::Plugin::'.$custom_module;
	   my $plugin = new $cx;
		my $log_level=$self->log_level();
		$plugin->log_level($log_level);
		my $snmp=$self->snmp();
		$plugin->snmp($snmp);

   	#my $plugin=Crawler::FXM::Plugin::$custom_module->new(log_level=>$log_level, 'snmp'=>$self);
   	$newvalues = $plugin->plugin_code($esp,$values,$desc);
	};
	if ($@) {
		$self->log('warning',"parse_fx:: [fx_PLUGIN] **WARN** ERROR EN MODULO $custom_module ($@)");
	}

	return $newvalues;
#	elsif ($custom_module eq 'STARIX') {
#	   my $nv = $self->fx_STARIX($esp,$values,$desc);
#      return $nv;
#   }
#	else {
#		$self->log('info',"parse_fx:: [fx_PLUGIN] **WARN** plugin_code NO CODIFICADA esp=@$esp values=@$values");
#		return $values; 
#	}
#}

}


1;
