#!/usr/bin/perl -w
#--------------------------------------------------------------------------------------
# NAME: cnm_informe_csv.pl
#
# DESCRIPTION:
# Genera el informe mensual de capacidad y disponibilidad en CSV, leyendo del
# servidor analitico. Sustituye al script que procesaba los RRDs.
#
# SE EJECUTA CONTRA TIMESCALE. No toca CNM.
#
# DOS FICHEROS por ejecucion:
#   <prefijo>-detalle.csv  una fila por INSTANCIA (disco, interfaz, KPI...)
#   <prefijo>-roles.csv    una fila por ROL, con el tiempo en alerta FUSIONADO
#
# Las columnas personalizadas del dispositivo (Application, Site, Geography...)
# se despliegan automaticamente: no van fijas en el codigo, se descubren de los
# datos. Asi el informe se adapta a cada instalacion sin tocar el script.
#
# CALLING SAMPLE:
#   cnm_informe_csv.pl --pg-host H --pg-db obs --pg-user U --pg-pass P --mes 2026-08
#   cnm_informe_csv.pl ... --desde 2026-08-01 --hasta 2026-09-01
#   cnm_informe_csv.pl ... --mes 2026-08 --rol 'site.es%'
#
# EXIT CODE: 0 OK | 1 argumentos | 4 error de PostgreSQL
#--------------------------------------------------------------------------------------
use strict;
use warnings;
use DBI;
use Getopt::Long;
use POSIX qw(strftime);

my $USAGE = <<'EOT';
cnm_informe_csv.pl --pg-host H --pg-db D --pg-user U --pg-pass P [opciones]
  --mes AAAA-MM      mes natural completo (alternativa a --desde/--hasta)
  --desde/--hasta    ventana explicita (AAAA-MM-DD)
  --rol PATRON       filtro sobre role_id. Admite dos formas:
                       patron LIKE : --rol 'site.es%'
                       lista       : --rol app.bi,app.bfc,site.es_ai_bcn
                     (si contiene comas se trata como lista exacta)
  --out PREFIJO      prefijo de los ficheros (por defecto CNM-Report-<mes>)
  --sep CAR          separador (por defecto ';', como el informe actual)
  --cols LISTA       columnas a incluir, separadas por comas y EN ESE ORDEN.
                     Por defecto todas. Ej: --cols role_id,dispositivo,p95,capacidad
  --cols-file F      igual, pero leyendo la lista de un fichero (una por linea,
                     '#' para comentarios). Util para perfiles de informe fijos.
  --list-cols        imprime las columnas disponibles y sale
  -v                 verboso
EOT

my %o = ('pg-host'=>'127.0.0.1','pg-port'=>5432,'pg-db'=>undef,
         'pg-user'=>undef,'pg-pass'=>undef,
         mes=>undef, desde=>undef, hasta=>undef, rol=>'%',
         out=>undef, sep=>';', cols=>undef, 'cols-file'=>undef,
         'list-cols'=>0, verbose=>0);
GetOptions(\%o,'pg-host=s','pg-port=i','pg-db=s','pg-user=s','pg-pass=s',
               'mes=s','desde=s','hasta=s','rol=s','out=s','sep=s',
               'cols=s','cols-file=s','list-cols!','verbose|v!','help|h')
  or die $USAGE;
die $USAGE if $o{help};
die $USAGE unless $o{'pg-db'} && $o{'pg-user'};

# --- ventana ---
if ($o{mes}) {
   $o{mes} =~ /^(\d{4})-(\d{2})$/ or die "--mes debe ser AAAA-MM\n";
   my ($y,$m) = ($1,$2+0);
   $o{desde} = sprintf("%04d-%02d-01", $y, $m);
   $o{hasta} = $m == 12 ? sprintf("%04d-01-01", $y+1) : sprintf("%04d-%02d-01", $y, $m+1);
}
die "Falta --mes o --desde/--hasta\n" unless $o{'list-cols'} || ($o{desde} && $o{hasta});

# --- seleccion de columnas ---
# Las columnas personalizadas del dispositivo se descubren de los datos, asi que
# tambien pueden nombrarse aqui (p.ej. 'Site', 'Application').
my @sel;
if ($o{'cols-file'}) {
   open(my $cf,'<',$o{'cols-file'}) or die "No puedo abrir $o{'cols-file'}: $!\n";
   # Se admite comentario al final de linea: 'p95   # valor de referencia'
   while (<$cf>) { s/#.*//; s/^\s+|\s+$//g; push @sel, $_ if length }
   close($cf);
}
push @sel, split(/\s*,\s*/, $o{cols}) if $o{cols};
$o{out} //= 'CNM-Report-'.($o{mes} // $o{desde});

sub vlog { print STDERR strftime("%H:%M:%S",localtime)." $_[0]\n" if $o{verbose} }

my $dbh = eval {
   DBI->connect("dbi:Pg:host=$o{'pg-host'};port=$o{'pg-port'};dbname=$o{'pg-db'}",
                $o{'pg-user'}, $o{'pg-pass'},
                {RaiseError=>1, PrintError=>0, AutoCommit=>1, pg_enable_utf8=>1});
};
unless ($dbh) { print STDERR "ERROR: no puedo conectar a PostgreSQL: $@\n"; exit 4 }

# Escapado CSV. El informe actual usa ';' y decimales con punto; se respeta.
sub csv {
   my ($v) = @_;
   return '' unless defined $v;
   $v =~ s/\r?\n/ /g;
   return '"'.($v =~ s/"/""/gr).'"' if $v =~ /["$o{sep}]/;
   return $v;
}

sub volcar {
   my ($fichero, $sql, $params, $expandir_json) = @_;
   my $sth = eval { my $s=$dbh->prepare($sql); $s->execute(@$params); $s };
   unless ($sth) { print STDERR "ERROR consultando: $@\n"; exit 4 }

   my @cols = @{ $sth->{NAME} };
   my $rows = $sth->fetchall_arrayref;
   vlog("$fichero: ".scalar(@$rows)." filas");

   # Las columnas personalizadas llegan como JSON en una sola columna. Se
   # descubren sus claves recorriendo los datos y se despliegan como columnas
   # propias: asi el CSV lleva 'Application', 'Site'... y no un blob JSON.
   my ($idx_json, @claves);
   if ($expandir_json) {
      ($idx_json) = grep { $cols[$_] eq 'dev_custom' } 0..$#cols;
      if (defined $idx_json) {
         my %k;
         for my $r (@$rows) {
            next unless defined $r->[$idx_json];
            $k{$1} = 1 while $r->[$idx_json] =~ /"([^"]+)"\s*:/g;
         }
         @claves = sort keys %k;
      }
   }

   open(my $fh, '>:encoding(UTF-8)', $fichero) or do {
      print STDERR "ERROR: no puedo escribir $fichero: $!\n"; exit 4 };

   my @cab = map { $cols[$_] } grep { !defined $idx_json || $_ != $idx_json } 0..$#cols;
   my @todas = (@cab, @claves);

   if ($o{'list-cols'}) {
      print "Columnas de $fichero:\n";
      print "  $_\n" for @todas;
      close($fh); unlink($fichero);
      return;
   }

   # Filtro y ORDEN de columnas. Las pedidas que no existan se avisan y se
   # ignoran, en vez de abortar: asi un perfil de columnas sigue sirviendo
   # aunque el informe gane o pierda alguna.
   my @idx = 0..$#todas;
   if (@sel) {
      my %pos; $pos{$todas[$_]} = $_ for 0..$#todas;
      my @falta = grep { !exists $pos{$_} } @sel;
      warn "AVISO: columnas inexistentes en $fichero, se ignoran: @falta\n" if @falta;
      @idx = map { $pos{$_} } grep { exists $pos{$_} } @sel;
      unless (@idx) { warn "AVISO: ninguna columna valida para $fichero; se vuelcan todas\n";
                      @idx = 0..$#todas; }
   }

   print $fh join($o{sep}, map { csv($todas[$_]) } @idx)."\n";

   for my $r (@$rows) {
      my @v = map { $r->[$_] } grep { !defined $idx_json || $_ != $idx_json } 0..$#cols;
      if (@claves) {
         my $j = $r->[$idx_json] // '';
         my %h; $h{$1} = $2 while $j =~ /"([^"]+)"\s*:\s*"([^"]*)"/g;
         push @v, map { $h{$_} } @claves;
      }
      print $fh join($o{sep}, map { csv($v[$_]) } @idx)."\n";
   }
   close($fh);
   return if $o{'list-cols'};
   printf "%s  (%d filas, %d columnas)\n", $fichero, scalar(@$rows), scalar(@idx);
}

if ($o{'list-cols'}) { $o{desde} //= '2000-01-01'; $o{hasta} //= '2000-01-02'; }
vlog("ventana: $o{desde} a $o{hasta}");
vlog("columnas seleccionadas: ".join(', ', @sel)) if @sel;

# El filtro de rol admite un patron LIKE o una LISTA separada por comas. Con
# lista se envuelve la llamada en un WHERE role_id = ANY(...): la funcion sigue
# recibiendo '%' y el filtrado se hace fuera, asi no hay que duplicar su firma
# ni construir SQL concatenando valores.
my (@ids, $filtro, @extra);
if ($o{rol} =~ /,/) {
   @ids = grep { length } map { s/^\s+|\s+$//gr } split(/,/, $o{rol});
   $filtro = ' WHERE role_id = ANY(?)';
   @extra  = ( '{'.join(',', map { my $v=$_; $v =~ s/(["\\])/\\$1/g; qq("$v") } @ids).'}' );
   vlog("filtro por lista de ".scalar(@ids)." roles");
} else {
   $filtro = '';
   vlog("filtro LIKE '$o{rol}'");
}
my $rol_sql = @ids ? '%' : $o{rol};

volcar("$o{out}-detalle.csv",
       "SELECT * FROM f_informe_capacidad(?::timestamptz, ?::timestamptz, ?)$filtro",
       [$o{desde}, $o{hasta}, $rol_sql, @extra], 1);

volcar("$o{out}-roles.csv",
       "SELECT * FROM f_informe_capacidad_rol(?::timestamptz, ?::timestamptz, ?)$filtro",
       [$o{desde}, $o{hasta}, $rol_sql, @extra], 0);

$dbh->disconnect;
exit 0;
