#!/usr/bin/perl -w
#-------------------------------------------------------------------------------------------
# Fichero: cpan-install.pl
#-------------------------------------------------------------------------------------------
use lib "/opt/cnm/crawler/bin/support";
use strict;
use warnings;
use Data::Dumper;
use ExtUtils::Installed;

#-------------------------------------------------------------------------------------------
# Nombre del archivo que contiene la lista de módulos y versiones a instalar
my $archivo_modulos = '/opt/cnm/os/debian11/cpan-modules.txt';

# Abrir el archivo que contiene la lista de módulos y versiones
open my $fh, '<', $archivo_modulos or die "No se pudo abrir el archivo $archivo_modulos: $!";

while (my $linea = <$fh>) {
    # Saltar líneas en blanco o líneas que comiencen con '#'
    next if $linea =~ /^\s*$/ or $linea =~ /^\s*#/;

    # Separar el nombre del módulo y la versión (si se proporciona)
    chomp $linea;
    my ($modulo, $version) = split /\s+/, $linea, 2;

    # Si no se proporciona una versión, utilizar la versión más reciente
    $version //= 0;

    # Instalar el módulo con la versión especificada
    install_module($modulo, $version);
}

close $fh;

#-------------------------------------------------------------------------------------------
sub install_module {
   my ($modulo, $version) = @_;
	
	my $instmod = ExtUtils::Installed->new();

	eval {
		$instmod->validate($modulo);
	};
	if (!$@) {
		my $vinst = $instmod->version($modulo) || "N/A";
		my $mismatch='   OK  ';
		if ($version ne $vinst) { $mismatch='**VER**'; } 
		print "MODULO: [$mismatch] INSTALLED $vinst|$version\t$modulo\n";
		return;
	}

	print "MODULO: [ Installing ... ] $modulo ";
	my $cmd = "cpanm -f -v $modulo > /tmp/$modulo.log 2>&1";
	system($cmd);
	$instmod = ExtUtils::Installed->new();
	$instmod->validate($modulo);
   my $vinst = $instmod->version($modulo) || "N/A";
   my $mismatch='';
   if ($version ne $vinst) { $mismatch='**VER**'; }
   print "INSTALLED $vinst|$version $mismatch\t$modulo\n";

}
