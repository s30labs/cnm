package CNMSemanticConf;
# =============================================================================
# CNMSemanticConf — carga la configuracion de la capa semantica de ESTA
# instalacion (parametros especificos del cliente), separandolos del codigo.
#
# POR QUE EXISTE: el vocabulario geografico, el filtro de servidores o el nombre
# de la BD son distintos en cada cliente. Si van incrustados en el codigo, el
# tooling deja de ser producto y pasa a ser "el script de este proyecto".
#
# FORMATO del fichero (semantic.conf):
#     clave = valor          # comentario
#     lista = A,B,C          # las listas se separan por comas
#
# ORDEN DE BUSQUEDA (gana el primero que exista):
#     1. la ruta pasada a load()            (opcion --conf)
#     2. $ENV{CNM_SEMANTIC_CONF}
#     3. /opt/data/semantic/semantic.conf   (ubicacion estandar: DATOS de cliente)
#     4. ./semantic.conf                    (directorio de trabajo)
# Si no se encuentra ninguno, se usan los DEFAULTS de abajo y se avisa por STDERR:
# el tooling sigue funcionando, pero conviene crear el fichero.
#
# USO:
#     use FindBin; use lib $FindBin::Bin;
#     use CNMSemanticConf;
#     my $cfg  = CNMSemanticConf->load($opt_conf);
#     my @geo  = $cfg->list('geography_vocab');
#     my $like = $cfg->get('server_type_like');
# =============================================================================
use strict;
use warnings;

# Valores por defecto = los del producto, NO los de un cliente concreto.
# geography_vocab se deja deliberadamente con solo 'WW': cualquier pais real es
# especifico del cliente y debe declararse en su semantic.conf.
my %DEFAULTS = (
   geography_vocab   => 'WW',
   server_type_like  => '%erver%',
   db_name           => 'onm',
   db_host           => '127.0.0.1',
   db_port           => '3306',
   data_dir          => '/opt/data/semantic',
   master_basename   => 'cnm_roles_maestro',
   iso2_whitelist    => '',          # si vacio, col8 usa geography_vocab
);

sub load {
   my ($class,$explicit) = @_;
   my @cand = grep { defined && length }
      ( $explicit,
        $ENV{CNM_SEMANTIC_CONF},
        '/opt/data/semantic/semantic.conf',
        './semantic.conf' );

   my ($path) = grep { -f $_ } @cand;
   my %kv = %DEFAULTS;

   if ($path) {
      open(my $fh,'<',$path) or die "No puedo leer $path: $!\n";
      my $ln=0;
      while (my $l = <$fh>) {
         $ln++;
         chomp $l;
         $l =~ s/#.*$//;               # comentarios
         next if $l =~ /^\s*$/;
         unless ($l =~ /^\s*([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.*?)\s*$/) {
            warn "AVISO: $path linea $ln ignorada (formato 'clave = valor'): $l\n";
            next;
         }
         $kv{$1} = $2;
      }
      close($fh);
   }
   else {
      warn "AVISO: no se encontro semantic.conf (buscado en: "
         . join(', ', grep { defined && length } @cand[1..$#cand])
         . "). Se usan valores por defecto del producto.\n";
   }

   my $self = { path=>$path, kv=>\%kv };
   return bless $self, $class;
}

# get('clave')          -> escalar (o el default si no esta)
sub get {
   my ($s,$k,$fallback) = @_;
   return $s->{kv}{$k} if defined $s->{kv}{$k} && $s->{kv}{$k} ne '';
   return $fallback if defined $fallback;
   return undef;
}

# list('clave')         -> lista (separada por comas, sin vacios, sin espacios)
sub list {
   my ($s,$k) = @_;
   my $v = $s->get($k);
   return () unless defined $v && $v ne '';
   my @out = grep { length } map { my $x=$_; $x=~s/^\s+|\s+$//g; $x } split(/\s*,\s*/,$v);
   return @out;
}

# de donde se cargo (para poder informarlo en la salida)
sub source { my $s=shift; return $s->{path} || '(valores por defecto)'; }

1;
