#####################################################################################################
# Fichero: (SupportDir.pm)
# Descripcion:
#	Donde escriben las herramientas de soporte (crawler/bin/support, designer/...): un unico
#	sitio, /store/data/support/<herramienta>/, con tres subdirectorios:
#	  state/   lo que la herramienta necesita entre ejecuciones. No se purga.
#	  backup/  copias de ficheros de configuracion antes de cambiarlos. No se purga.
#	  runs/    lo que produce cada ejecucion, en runs/AAAAMMDD-HHMMSS[-etiqueta]/.
#	           cnm-daily borra las de mas de SUPPORT_RETENTION_DAYS dias (30 por defecto),
#	           salvo las que tienen un fichero KEEP.
#	La raiz se cambia con la variable CNM_SUPPORT_DIR (pruebas).
#	Lo usan las herramientas y cnm-daily. Regla: cnm-docs, REF-CNM-Estilo-Scripts §2.9.
# Set Tab=3
#####################################################################################################
package SupportDir;
$VERSION='1.00';
use strict;
use POSIX qw(strftime);
use Time::Local qw(timelocal);
use File::Path qw(make_path remove_tree);
require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(SUPPORT_ROOT RETENTION_DAYS support_root valid_tool support_dir new_run_dir
						 run_stamp purge_candidates purge_runs);

use constant SUPPORT_ROOT   => '/store/data/support';
use constant RETENTION_DAYS => 30;
my %KINDS = ( state=>1, backup=>1, runs=>1 );

#----------------------------------------------------------------------------
# support_root() -> la raiz: CNM_SUPPORT_DIR o /store/data/support
#----------------------------------------------------------------------------
sub support_root { return ($ENV{'CNM_SUPPORT_DIR'} && ($ENV{'CNM_SUPPORT_DIR'} ne '')) ? $ENV{'CNM_SUPPORT_DIR'} : SUPPORT_ROOT; }

#----------------------------------------------------------------------------
# valid_tool($name) -> 1 si es un nombre de herramienta valido (minusculas, numeros, . _ -)
#----------------------------------------------------------------------------
sub valid_tool { my $n=shift; return ((defined $n) && ($n =~ /^[a-z0-9][a-z0-9._-]*$/)) ? 1 : 0; }

#----------------------------------------------------------------------------
# support_dir($tool,$kind,$create) -> ruta de state, backup o runs de la herramienta.
# Con $create, la crea (modo 0700). Muere con un nombre o un tipo no validos.
#----------------------------------------------------------------------------
sub support_dir {
my ($tool,$kind,$create)=@_;
	die "SupportDir: nombre de herramienta no valido: ".((defined $tool) ? $tool : 'undef')."\n" if (! valid_tool($tool));
	die "SupportDir: tipo no valido: ".((defined $kind) ? $kind : 'undef')." (state, backup o runs)\n" if ((! defined $kind) || (! $KINDS{$kind}));
	my $d = support_root()."/$tool/$kind";
	if ($create) {
		make_path($d, { mode=>0700 }) if (! -d $d);
		die "SupportDir: no se puede crear $d\n" if (! -d $d);
	}
	return $d;
}

#----------------------------------------------------------------------------
# new_run_dir($tool,$label,$now) -> crea runs/AAAAMMDD-HHMMSS[-etiqueta]/ y devuelve la ruta.
# Si ya existe (dos ejecuciones en el mismo segundo), anade .1, .2...
#----------------------------------------------------------------------------
sub new_run_dir {
my ($tool,$label,$now)=@_;
	die "SupportDir: etiqueta no valida: $label\n" if ((defined $label) && ($label ne '') && ($label !~ /^[A-Za-z0-9._-]+$/));
	my $base = support_dir($tool,'runs',1).'/'.strftime('%Y%m%d-%H%M%S', localtime((defined $now) ? $now : time()));
	$base .= "-$label" if ((defined $label) && ($label ne ''));
	my ($d,$i)=($base,1);
	while (-e $d) { $d="$base.$i"; $i++; }
	mkdir($d,0700) or die "SupportDir: no se puede crear $d: $!\n";
	return $d;
}

#----------------------------------------------------------------------------
# run_stamp($name) -> epoch de la fecha con la que empieza el nombre de una ejecucion, o undef
#----------------------------------------------------------------------------
sub run_stamp {
my $name=shift;
	return undef if ((! defined $name) || ($name !~ /^(\d{4})(\d\d)(\d\d)-(\d\d)(\d\d)(\d\d)/));
	my $t = eval { timelocal($6,$5,$4,$3,$2-1,$1) };
	return $t;
}

#----------------------------------------------------------------------------
# purge_candidates(\@entries,$days,$now) -> rutas a borrar. Funcion pura.
# @entries: { path, name, isdir, mtime, keep } de lo que hay en un runs/.
# Se borra un directorio con KEEP ausente y mas antiguo que $days dias, por la fecha de su
# nombre (o por mtime si el nombre no la lleva). Lo que no es directorio no se toca.
#----------------------------------------------------------------------------
sub purge_candidates {
my ($entries,$days,$now)=@_;
	my $limit = $now - $days*86400;
	my @d=();
	foreach my $e (@$entries) {
		next if ((! $e->{'isdir'}) || ($e->{'keep'}));
		my $t = run_stamp($e->{'name'});
		$t = $e->{'mtime'} if (! defined $t);
		push @d, $e->{'path'} if ((defined $t) && ($t < $limit));
	}
	return @d;
}

#----------------------------------------------------------------------------
# purge_runs($days,$dry,$now) -> rutas borradas (o que se borrarian, con $dry).
# Recorre support_root()/*/runs/. Solo borra dentro de un runs/.
#----------------------------------------------------------------------------
sub purge_runs {
my ($days,$dry,$now)=@_;
	$now = time() if (! defined $now);
	my $root = support_root();
	return () if (! -d $root);
	my @done=();
	my $dh;
	opendir($dh,$root) or die "SupportDir: no se puede leer $root: $!\n";
	my @tools = grep { valid_tool($_) && (-d "$root/$_/runs") } readdir($dh);
	closedir($dh);
	foreach my $t (sort @tools) {
		my $runs = "$root/$t/runs";
		opendir($dh,$runs) or next;
		my @e = map { my $p="$runs/$_"; { path=>$p, name=>$_, isdir=>((-d $p) && (! -l $p)) ? 1 : 0,
							mtime=>(stat($p))[9], keep=>(-e "$p/KEEP") ? 1 : 0 } }
					grep { ($_ ne '.') && ($_ ne '..') } readdir($dh);
		closedir($dh);
		foreach my $p (purge_candidates(\@e,$days,$now)) {
			next if (index($p,"$runs/") != 0);	# solo dentro de runs/
			remove_tree($p) if (! $dry);
			push @done, $p;
		}
	}
	return @done;
}

1;
__END__
