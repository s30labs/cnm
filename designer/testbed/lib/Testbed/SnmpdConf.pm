#####################################################################################################
# Fichero: (Testbed::SnmpdConf.pm)
# Descripcion:
#	Anade, cambia o quita un bloque con nombre en el texto de snmpd.conf, entre las lineas
#	"# cnm-testbed:NOMBRE begin" y "# cnm-testbed:NOMBRE end". El resto del fichero no se
#	toca. Funciones puras: reciben y devuelven texto; leer y escribir el fichero lo hace
#	cnm-testbed. Diseno: cnm-docs, PROY-CNM-Alertas-Azules §6.
# Set Tab=3
#####################################################################################################
package Testbed::SnmpdConf;
$VERSION='1.00';
use strict;
require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(has_block set_block remove_block block_names);

sub _marks {
my $name=shift;
	return ("# cnm-testbed:$name begin", "# cnm-testbed:$name end");
}

#----------------------------------------------------------------------------
# has_block($text,$name) -> 1 si el bloque esta
#----------------------------------------------------------------------------
sub has_block {
my ($text,$name)=@_;
	my ($b,$e)=_marks($name);
	return ($text =~ /(?:\A|\n)\Q$b\E\n.*?\Q$e\E(?:\n|\z)/s) ? 1 : 0;
}

#----------------------------------------------------------------------------
# remove_block($text,$name) -> texto sin el bloque (y sin la linea en blanco que lo precede)
#----------------------------------------------------------------------------
sub remove_block {
my ($text,$name)=@_;
	my ($b,$e)=_marks($name);
	$text =~ s/(?:\A|\n)\n?\Q$b\E\n.*?\Q$e\E(?:\n|\z)/\n/s;
	$text =~ s/\A\n// if ($text =~ /\A\n/);
	return $text;
}

#----------------------------------------------------------------------------
# set_block($text,$name,\@lines) -> texto con el bloque al final (sustituye al que hubiera)
#----------------------------------------------------------------------------
sub set_block {
my ($text,$name,$lines)=@_;
	my ($b,$e)=_marks($name);
	$text = remove_block($text,$name);
	$text .= "\n" if (($text ne '') && ($text !~ /\n$/));
	return $text."\n$b\n".join("\n",@$lines)."\n$e\n";
}

#----------------------------------------------------------------------------
# block_names($text) -> nombres de los bloques cnm-testbed que hay en el texto
#----------------------------------------------------------------------------
sub block_names {
my $text=shift;
	my @n=();
	while ($text =~ /^# cnm-testbed:(\S+) begin$/mg) { push @n, $1; }
	return @n;
}

1;
__END__
