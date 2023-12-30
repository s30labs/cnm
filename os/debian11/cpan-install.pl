#!/usr/bin/perl -w
#-------------------------------------------------------------------------------------------
# Fichero: cpan-install.pl
#-------------------------------------------------------------------------------------------
use lib "/opt/cnm/crawler/bin/support";
use strict;
use warnings;
use Getopt::Std;
use Data::Dumper;
use ExtUtils::Installed;

#-------------------------------------------------------------------------------------------
my %opts=();
getopts("i",\%opts);

if ($opts{h}) { my $USAGE = usage(); die $USAGE;}

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

   if ($opts{i}) { install_module($modulo, $version); }
	else { check_module($modulo, $version); }
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

	my $vinst = "N/A";
	eval {
   	$instmod->validate($modulo);
	};
	if ($@) { print " ++No validation++ "; }
	else { $vinst = $instmod->version($modulo) || "N/A"; }

   my $mismatch='';
   if ($version ne $vinst) { $mismatch='**VER**'; }
   print "INSTALLED $vinst|$version $mismatch\t$modulo\n";

}

#-------------------------------------------------------------------------------------------
sub check_module {
   my ($modulo, $version) = @_;

   my $instmod = ExtUtils::Installed->new();

   eval {
      $instmod->validate($modulo);
   };
   if (!$@) {
      my $vinst = $instmod->version($modulo) || "N/A";
   	my $cmd = "cpanm --info $modulo";
   	my $info=`$cmd`;
   	chomp $info;
#print "---$info----\n";
   	my $cpan_version = '';
   	if ($info =~/^\S+\-(\S+)\.tar\.gz$/) { $cpan_version = $1; }
   	elsif ($info =~/^\S+\-(\S+)\.tgz$/) { $cpan_version = $1; }
		my $mismatch='   OK  ';
   	if ($cpan_version ne $vinst) { $mismatch='**VER**'; }

      print "MODULO: [$mismatch] INSTALLED $vinst|$cpan_version\t$modulo\n";
      return;
   }

   print "MODULO: [ UNK  ] $modulo\n";

}

#-------------------------------------------------------------------------------------------
sub usage {

   my @fpth = split ('/',$0,10);
   my @fname = split ('\.',$fpth[$#fpth],10);
   my $USAGE = <<USAGE;
PERL modules installer

$fpth[$#fpth] -h  : Ayuda
$fpth[$#fpth] -l  : Lista informacion

USAGE

   return $USAGE;

}

