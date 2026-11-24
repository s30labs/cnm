#####################################################################################################
# Fichero: (ProvisionLite::RrdRemap.pm)
# Descripcion:
#	Los RRD siguen a su etiqueta cuando las instancias cambian de iid (el "R2" de
#	PROY-CNM-Alertas-Azules, apartado 5.3; REG-CNM-Deuda 4.107).
#
#	El RRD se llama por el nombre de la metrica (subtipo-iid) y el recolector escribe
#	por iid. Si una etiqueta pasa del iid 64 al 55, su historico esta en el fichero
#	del 64 y la metrica que la mide ahora escribe en el del 55. Aqui se mueven los
#	ficheros para que cada historico quede en el nombre del iid nuevo de su etiqueta.
#
#	Los ficheros se intercambian con renameat2(RENAME_EXCHANGE): en ningun momento
#	falta ninguno de los dos, y el recolector, que crea vacio un RRD que no existe, no
#	puede pisar el historico que se mueve. Si uno de los dos no existe se mueve con
#	RENAME_NOREPLACE, que no pisa un fichero que haya aparecido entretanto.
#
#	swap_plan es pura; rrd_swap toca el disco. Las llama ProvisionLite.pm.
# Set Tab=3
#####################################################################################################
package ProvisionLite::RrdRemap;
$VERSION='1.00';
use strict;
require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(swap_plan apply_plan_to rrd_swap rename2_supported);

# renameat2 en x86_64 (asm/unistd_64.h); los appliances son x86_64
use constant SYS_RENAMEAT2    => 316;
use constant AT_FDCWD         => -100;
use constant RENAME_NOREPLACE => 1;
use constant RENAME_EXCHANGE  => 2;
use constant EEXIST           => 17;

#----------------------------------------------------------------------------
# swap_plan(\@moves) -> [ [a,b], ... ]
#
# @moves: [ { from=>iid, to=>iid }, ... ]: el contenido del fichero de "from" tiene que
# acabar en el fichero de "to". Cada from y cada to aparecen una sola vez (lo garantiza
# LabelRemap::remap_by_label: las etiquetas repetidas no se mueven).
#
# Devuelve los intercambios, por orden. Los movimientos forman cadenas (a->b->c, donde
# "a" no recibe nada y "c" no da nada) y ciclos (a->b->a). Una cadena se cierra
# devolviendo al principio lo que habia en el ultimo (c->a): lo que habia en "c" no es
# de ninguna etiqueta que siga viva y queda en el fichero de "a", que la provision
# retirara si su fila se quita. Un ciclo c1->c2->...->cm se hace con m-1 intercambios,
# todos con c1: (c1,c2), (c1,c3), ..., (c1,cm).
#----------------------------------------------------------------------------
sub swap_plan {
my $moves=shift;
	my (%next,%has_in);
	foreach my $m (@{$moves || []}) {
		my ($f,$t)=($m->{'from'},$m->{'to'});
		next if ((! defined $f) || (! defined $t) || ($f eq $t));
		$next{$f}=$t;
		$has_in{$t}=1;
	}
	# Cadenas: se cierran en ciclo
	foreach my $s (sort keys %next) {
		next if ($has_in{$s});
		my $e=$s;
		my %seen=();
		while (exists $next{$e}) { last if ($seen{$e}++); $e=$next{$e}; }
		$next{$e}=$s if (! exists $next{$e});
	}
	# Ciclos
	my (@plan,%done);
	foreach my $c1 (sort keys %next) {
		next if ($done{$c1});
		$done{$c1}=1;
		my $x=$next{$c1};
		while ((defined $x) && ($x ne $c1) && (! $done{$x})) {
			push @plan, [ $c1, $x ];
			$done{$x}=1;
			$x=$next{$x};
		}
	}
	return \@plan;
}

#----------------------------------------------------------------------------
# apply_plan_to(\%content,\@plan) -> copia de %content tras los intercambios. Pura: la
# usan las pruebas para comprobar un plan sin tocar el disco.
#----------------------------------------------------------------------------
sub apply_plan_to {
my ($content,$plan)=@_;
	my %c=%{$content || {}};
	foreach my $p (@{$plan || []}) {
		my ($x,$y)=@$p;
		my ($ex,$ey)=(exists $c{$x},exists $c{$y});
		my ($vx,$vy)=($c{$x},$c{$y});
		delete $c{$x}; delete $c{$y};
		$c{$y}=$vx if ($ex);
		$c{$x}=$vy if ($ey);
	}
	return \%c;
}

#----------------------------------------------------------------------------
# rename2_supported() -> 1 si se puede usar renameat2 con el numero de x86_64
#----------------------------------------------------------------------------
sub rename2_supported {
	require POSIX;
	my $m=(POSIX::uname())[4];
	return ((defined $m) && ($m eq 'x86_64')) ? 1 : 0;
}

sub _renameat2 {
my ($x,$y,$flags)=@_;
	# syscall necesita escalares modificables
	my ($sx,$sy)=("$x","$y");
	my $r=syscall(SYS_RENAMEAT2, AT_FDCWD, $sx, AT_FDCWD, $sy, $flags);
	return ($r == 0) ? 0 : ($!+0);
}

#----------------------------------------------------------------------------
# rrd_swap($pa,$pb) -> (1,$como) o (0,$error)
# Intercambia el contenido de dos rutas. Si las dos existen, RENAME_EXCHANGE. Si solo
# existe una, se mueve a la otra con RENAME_NOREPLACE; si la otra aparece entretanto
# (EEXIST: el recolector la ha creado), se intercambian. Si no existe ninguna, nada.
# Hacerlo dos veces deja todo como estaba: sirve para deshacer.
#----------------------------------------------------------------------------
sub rrd_swap {
my ($pa,$pb)=@_;
	my ($ea,$eb)=(-e $pa ? 1 : 0, -e $pb ? 1 : 0);
	return (1,'ninguno') if ((! $ea) && (! $eb));
	if ($ea && $eb) {
		my $e=_renameat2($pa,$pb,RENAME_EXCHANGE);
		return ($e == 0) ? (1,'intercambio') : (0,"intercambio: errno $e");
	}
	my ($src,$dst) = $ea ? ($pa,$pb) : ($pb,$pa);
	my $e=_renameat2($src,$dst,RENAME_NOREPLACE);
	return (1,'movido') if ($e == 0);
	if ($e == EEXIST) {
		$e=_renameat2($pa,$pb,RENAME_EXCHANGE);
		return ($e == 0) ? (1,'intercambio') : (0,"intercambio tras EEXIST: errno $e");
	}
	return (0,"movido: errno $e");
}

1;
__END__
