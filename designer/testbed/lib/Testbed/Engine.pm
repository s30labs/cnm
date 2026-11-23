#####################################################################################################
# Fichero: (Testbed::Engine.pm)
# Descripcion:
#	Si hay que reiniciar el motor de CNM para que los crawlers vean la MIB de prueba.
#	Funciones puras. El crawler pide los valores por nombre de la MIB (cnmTestbedValue) y un
#	proceso arrancado antes de instalar la MIB no lo resuelve: "ERROR = -58 (Unknown Object
#	Identifier)" en crawler_debug.log (Crawler/SNMP.pm:4186 y 4297) y la metrica en azul.
#	Medido en cnm-11-8-test el 21-nov-2026: [crawler.4000.snmp.300] arrancado a las 07:40,
#	MIB instalada a las 18:19.
#	Diseno: cnm-docs, PROY-CNM-Alertas-Azules §6.
# Set Tab=3
#####################################################################################################
package Testbed::Engine;
$VERSION='1.00';
use strict;
require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(parse_ps crawlers stale_crawlers);

#----------------------------------------------------------------------------
# parse_ps($text,$now) -> [ {pid,start,args}, ... ] de la salida de "ps -eo pid=,etimes=,args="
# start = $now - etimes (segundos desde que arranco)
#----------------------------------------------------------------------------
sub parse_ps {
my ($text,$now)=@_;
	my @r=();
	foreach my $l (split(/\n/, (defined $text) ? $text : '')) {
		next if ($l !~ /^\s*(\d+)\s+(\d+)\s+(.*?)\s*$/);
		push @r, { pid=>$1, start=>$now-$2, args=>$3 };
	}
	return \@r;
}

#----------------------------------------------------------------------------
# crawlers(\@procs) -> los procesos del crawler: los que se llaman "[crawler.xxx]"
# (como [crawler.4000.snmp.300]). No cuenta los que solo llevan /opt/crawler/ en la ruta.
#----------------------------------------------------------------------------
sub crawlers {
my $p=shift;
	return [ grep { $_->{'args'} =~ /^\[crawler\.[^\]]+\]/ } @{$p || []} ];
}

#----------------------------------------------------------------------------
# stale_crawlers(\@procs,$mib_mtime) -> crawlers arrancados antes de instalar la MIB
#----------------------------------------------------------------------------
sub stale_crawlers {
my ($p,$mtime)=@_;
	return [ grep { $_->{'start'} < $mtime } @{crawlers($p)} ];
}

1;
__END__
