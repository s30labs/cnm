#!/usr/bin/perl -w
#--------------------------------------------------------------------------------------
# NAME: cnm_ts_sync_semantics.pl
#
# DESCRIPTION:
# Replica la capa semantica de CNM (MariaDB, base onm) al servidor Timescale
# (PostgreSQL, base obs), en DOS tablas:
#   sem_role_lookup -> instancia + rol + semantica de la senal (~6.500 filas)
#   sem_metric_map  -> puente id_metric -> instancia        (~22.900 filas)
#
# La segunda es la que permite unir cnm_alerts_store (que trae id_metric) con
# sem_role_lookup (indexada por sem_instance_id). Sin ella no hay forma de llegar
# del historico de alertas al rol de negocio.
#
# NO es un ETL incremental: reemplaza la tabla ENTERA en cada pasada, dentro de
# UNA transaccion. Son ~6.500 filas; el coste es despreciable y elimina toda la
# clase de errores de sincronizacion parcial.
#
# DIRECCION DEL FLUJO: se ejecuta en el host de CNM (donde MariaDB es local) y
# EMPUJA hacia Timescale. Reutiliza el mismo sentido de confianza que el loader
# de ingesta; no requiere abrir MariaDB a la red ni instalar FDW en Timescale.
#
# GARANTIAS:
#  a. Atomica: o se publica la foto completa o no se toca nada (ROLLBACK).
#  b. Nunca deja la tabla vacia ni truncada a medias.
#  c. Se NIEGA a publicar si el origen encoge de forma sospechosa (--max-shrink-pct)
#     o devuelve menos de --min-rows filas: protege contra una lectura parcial
#     que borraria la capa analitica sin previo aviso.
#  d. --dry-run para validar sin escribir.
#
# CALLING SAMPLE:
# cnm_ts_sync_semantics.pl --pg-host 10.x.x.x --pg-db obs --pg-user u --pg-pass p
# cnm_ts_sync_semantics.pl ... --dry-run -v
# cnm_ts_sync_semantics.pl ... --check-schema      (solo valida el origen y sale)
#
# EXIT CODE:
#  0: OK (o dry-run correcto)
#  1: error de argumentos
#  2: el esquema origen no coincide con el esperado
#  3: error de conexion o de lectura en MariaDB
#  4: error de escritura en PostgreSQL (se ha hecho ROLLBACK)
#  5: salvaguarda activada: el origen encogio mas de lo permitido (no se publica)
#
# PROGRAMACION: timer de systemd cada hora. El binding no cambia por minutos;
# una hora de desfase es irrelevante para agregacion de salud.
#--------------------------------------------------------------------------------------
use strict;
use warnings;
use DBI;
use Getopt::Long;
use POSIX qw(strftime);

my $USAGE = <<'EOT';
cnm_ts_sync_semantics.pl --pg-host H --pg-db D --pg-user U --pg-pass P [opciones]
  --pg-host/--pg-port/--pg-db/--pg-user/--pg-pass  destino PostgreSQL
  --my-db            base MariaDB origen (por defecto onm)
  --my-host          host MariaDB (por defecto localhost)
  --my-user/--my-pass credencial de MariaDB
  --min-rows N       no publicar si el origen devuelve menos de N filas (def. 100)
  --max-shrink-pct P no publicar si encoge mas de un P% respecto a lo publicado (def. 30)
  --dry-run          lee, valida y muestra el resumen, pero NO escribe
  --check-schema     solo valida las columnas del origen y sale
  -v                 verboso
EOT

my %o = ( 'pg-host'=>'127.0.0.1', 'pg-port'=>5432, 'pg-db'=>undef,
          'pg-user'=>undef, 'pg-pass'=>undef,
          'my-db'=>'onm', 'my-host'=>'localhost',
          'my-user'=>undef, 'my-pass'=>undef,
          'min-rows'=>100, 'max-shrink-pct'=>30,
          'dry-run'=>0, 'check-schema'=>0, verbose=>0 );
GetOptions(\%o, 'pg-host=s','pg-port=i','pg-db=s','pg-user=s','pg-pass=s',
                'my-db=s','my-host=s','my-user=s','my-pass=s',
                'min-rows=i','max-shrink-pct=i',
                'dry-run!','check-schema!','verbose|v!','help|h')
   or die $USAGE;
die $USAGE if $o{help};
die $USAGE unless $o{'check-schema'} || ($o{'pg-db'} && $o{'pg-user'});

sub ts   { strftime("%Y-%m-%d %H:%M:%S", localtime) }
sub vlog { print ts()." [sync] $_[0]\n" if $o{verbose} }
sub elog { print STDERR ts()." [sync] ERROR: $_[0]\n" }

# =============================================================================
# CONSULTA ORIGEN  ·  UNICO PUNTO ACOPLADO AL ESQUEMA DE CNM
#
# Si el modelo semantico cambia, SOLO hay que tocar esto (y @SRC_REQUIRED).
# El orden de las columnas debe coincidir con @DST_COLS.
#
# Notas de diseno:
#  - signal_class EFECTIVA: se resuelve aqui (COALESCE override -> concepto).
#    Es una regla fija del modelo, no un juicio, asi que se materializa una vez
#    en lugar de reimplementarla en cada consulta analitica.
#  - LEFT JOIN al concepto: un binding sin concepto asociado NO debe desaparecer
#    de la replica; aparece con signal_class NULL y las vistas de gobernanza lo
#    dejan a la vista.
#  - Solo roles activos: un binding a un rol dado de baja no debe agregar.
# =============================================================================
my $SRC_SQL = <<'SQL';
SELECT  b.instance_id, b.role_id, b.relation_type, b.is_primary, b.weight,
        b.confidence, b.source,
        r.display_name, r.role_type, r.domain, r.criticality, r.environment,
        r.health_threshold, r.health_threshold_note,
        COALESCE(b.signal_class_override, c.signal_class) AS signal_class,
        c.canonical_id, c.display_name AS concepto_nombre,
        c.category, c.direction, c.unit, c.is_business, c.scope,
        COALESCE(mc.value_scale, 1.0) AS value_scale,
        i.capacity,
        COALESCE(c.needs_instance_capacity, 0) AS needs_capacity,
        i.expected_value, c.plausible_min, c.plausible_max,
        i.subtype, i.stable_key, i.iddev
FROM        sem_binding_role      b
INNER JOIN  sem_business_role     r  ON r.role_id     = b.role_id
INNER JOIN  sem_instance          i  ON i.instance_id = b.instance_id
LEFT  JOIN  sem_metric_concept    mc ON mc.subtype    = i.subtype
LEFT  JOIN  sem_canonical_concept c
       ON c.canonical_id = COALESCE(i.canonical_override, mc.canonical_id)
WHERE r.status = 'active'
  AND (r.valid_to IS NULL OR r.valid_to >= CURDATE())
SQL

# Columnas del destino, EN EL MISMO ORDEN que el SELECT anterior.
my @DST_COLS = qw(sem_instance_id role_id relation_type is_primary weight
                  binding_confidence binding_source
                  role_display_name role_type role_domain criticality environment
                  health_threshold health_threshold_note
                  signal_class canonical_id concepto_nombre
                  category direction unit is_business scope
                  value_scale capacity needs_capacity expected_value
                  plausible_min plausible_max
                  subtype stable_key iddev);

# =============================================================================
# CONSULTA DEL PUENTE id_metric -> instancia
#
# iddev/subtype/stable_key vienen desnormalizados de sem_instance: sirven de
# CANARIO para detectar un id_metric reutilizado tras un cambio de topologia
# (ver v_alertas_canario_identidad). No filtran nada.
#
# SIN filtro por valid_to ni por status: la PK de sem_metric_binding es idmetric
# a secas, luego hay como mucho UNA fila por metrica y siempre refleja su
# instancia actual. Descartar las 'stale' solo perderia la atribucion de alertas
# de metricas recien retiradas, que son historicamente validas.
# =============================================================================
# El SELECT se construye en tiempo de ejecucion porque el numero de columnas
# personalizadas (devices_custom_data.columnaN) VARIA entre instalaciones: el
# dump de referencia tiene 6 y esta produccion tiene 8. Se leen de
# information_schema y se etiquetan con su nombre funcional segun
# devices_custom_types (id N -> columnaN). Ver build_map_sql().
my $MAP_SQL;                      # se rellena en build_map_sql()
my @MAP_COLS = qw(idmetric instance_id iddev subtype stable_key
                  dev_name dev_ip dev_status dev_custom
                  metric_name metric_label metric_type
                  monitor monitor_causa monitor_expr monitor_severidad);

# Construye el SELECT del mapa incluyendo las columnas personalizadas que
# realmente existan, empaquetadas como JSON con su nombre funcional.
#   devices_custom_types: id=1 descr='Application' -> columna1
#   Valores '-' (el defecto de CNM para "sin dato") se omiten del JSON.
sub build_map_sql {
   my ($mh) = @_;

   my $cols = $mh->selectcol_arrayref(
      "SELECT column_name FROM information_schema.columns
        WHERE table_schema = ? AND table_name = 'devices_custom_data'
          AND column_name LIKE 'columna%'
        ORDER BY CAST(SUBSTRING(column_name,8) AS UNSIGNED)", undef, $o{'my-db'});

   my %etiqueta;
   my $t = eval { $mh->selectall_arrayref("SELECT id, descr FROM devices_custom_types") };
   $etiqueta{'columna'.$_->[0]} = $_->[1] for @{ $t || [] };

   # CONCAT manual en vez de JSON_OBJECT: MySQL 5.5 no tiene funciones JSON.
   my @pares;
   for my $c (@$cols) {
      my $lab = $etiqueta{$c} // $c;
      $lab =~ s/"/\\"/g;
      push @pares, "IF(dc.`$c` IS NULL OR dc.`$c` = '-' OR dc.`$c` = '', NULL, "
                 . "CONCAT('\"$lab\":', '\"', REPLACE(dc.`$c`,'\"','\\\\\"'), '\"'))";
   }
   my $json = @pares
      ? "CONCAT('{', CONCAT_WS(',', ".join(',', @pares)."), '}')"
      : "'{}'";

   # Vinculo con lo que se ve en la consola de CNM. Significado EXACTO de cada
   # campo, verificado contra el esquema (no inferido del nombre):
   #
   #   metrics.name   -> subtype + iid cuando hay instancia; solo subtype si no.
   #                     NO es el monitor. Forma parte de la PK junto a id_dev.
   #   metrics.label  -> etiqueta descriptiva. La que se ve en graficas y alertas.
   #                     Ej: 'USO DE DISCO C:\ Label: (dwdata06.areas2.com)'
   #   metrics.type   -> familia: snmp, latency, xagent
   #   metrics.watch  -> EL MONITOR. Cruza con alert_type.monitor
   #   metrics.mtype  -> tipo de RRD y presentacion visual de la grafica.
   #                     NO se replica: no aporta nada al analisis.
   #
   # De alert_type se traen los umbrales, que es lo que permite contrastar el
   # modelo semantico con lo que esta realmente configurado en CNM:
   #   cause    -> el umbral en lenguaje natural: 'Disk Usage Higher than 80% - 90%'
   #   expr     -> la expresion evaluada
   #   severity -> severidad que produce
   #
   # watch = '0' significa metrica sin monitor: el LEFT JOIN la deja en NULL.
   #
   # FILTRO mb.status = 'active'. IMPRESCINDIBLE: sin el, se replicaban tambien
   # los bindings 'stale' -616 en agosto de 2026- cuyas metricas ya no existen en
   # CNM. Aparecian en el mapa con todos los campos de metrics a NULL y sin un
   # solo dato, inflando los recuentos de cobertura.
   #
   # devices.status se replica pero NO se filtra aqui, a proposito:
   #   0 = activo   1 = de baja (sin polling)   2 = mantenimiento (polling sin alertar)
   # Excluirlos en el sync seria decidir por el consumidor. Se expone el dato y
   # cada vista decide. Ver REV-SEM-05.
   $MAP_SQL = <<"SQL";
SELECT mb.idmetric, mb.instance_id, i.iddev, i.subtype, i.stable_key,
       d.name AS dev_name, d.ip AS dev_ip,
       COALESCE(d.status, 0) AS dev_status,
       $json  AS dev_custom,
       me.name  AS metric_name,
       me.label AS metric_label,
       me.type  AS metric_type,
       NULLIF(me.watch, '0') AS monitor,
       at.cause    AS monitor_causa,
       at.expr     AS monitor_expr,
       at.severity AS monitor_severidad
FROM       sem_metric_binding mb
INNER JOIN sem_instance         i  ON i.instance_id = mb.instance_id
LEFT  JOIN metrics              me ON me.id_metric  = mb.idmetric
LEFT  JOIN alert_type           at ON at.monitor    = me.watch AND me.watch <> '0'
LEFT  JOIN devices              d  ON d.id_dev = i.iddev
LEFT  JOIN devices_custom_data  dc ON dc.id_dev = i.iddev
WHERE mb.status = 'active'
SQL
   vlog(sprintf("mapa: %d columnas personalizadas (%s)", scalar @$cols,
                join(', ', map { $etiqueta{$_} // $_ } @$cols)));
   return 1;
}

# Columnas que DEBEN existir en el origen (verificadas contra information_schema).
my %SRC_REQUIRED = (
   sem_binding_role      => [qw(instance_id role_id relation_type is_primary
                                weight signal_class_override confidence source)],
   sem_business_role     => [qw(role_id display_name role_type domain criticality
                                environment status valid_to
                                health_threshold health_threshold_note)],
   sem_instance          => [qw(instance_id iddev subtype stable_key
                                canonical_override capacity expected_value)],
   sem_metric_concept    => [qw(subtype canonical_id value_scale)],
   sem_metric_binding    => [qw(idmetric instance_id)],
   devices               => [qw(id_dev name ip)],
   metrics               => [qw(id_metric name label type watch)],
   alert_type            => [qw(monitor cause expr severity)],
   devices_custom_data   => [qw(id_dev)],
   devices_custom_types  => [qw(id descr)],
   sem_canonical_concept => [qw(canonical_id display_name signal_class category direction unit
                                is_business scope needs_instance_capacity
                                plausible_min plausible_max)],
);

# =============================================================================
# Conexiones
# =============================================================================
sub connect_mysql {
   # CONVENCION DE CREDENCIALES: misma que cnm_ts_loader.pl (linea de comandos).
   my $dsn = "dbi:mysql:database=$o{'my-db'};host=$o{'my-host'}";
   my $h = eval { DBI->connect($dsn, $o{'my-user'}, $o{'my-pass'},
             {RaiseError=>1, PrintError=>0, AutoCommit=>1, mysql_connect_timeout=>15}) };
   unless ($h) { elog("no puedo conectar a MariaDB ($o{'my-db'}\@$o{'my-host'}): $@"); exit 3 }
   # Las tablas sem_* son utf8, pero si la conexion negocia latin1 el servidor
   # transcodifica al vuelo y destroza los acentos de display_name/label.
   eval { $h->do("SET NAMES utf8") };
   return $h;
}

sub connect_pg {
   my $dsn = "dbi:Pg:host=$o{'pg-host'};port=$o{'pg-port'};dbname=$o{'pg-db'}";
   my $h = eval { DBI->connect($dsn, $o{'pg-user'}, $o{'pg-pass'},
             {RaiseError=>1, PrintError=>0, AutoCommit=>0}) };
   unless ($h) { elog("no puedo conectar a PostgreSQL: $@"); exit 4 }
   return $h;
}

# =============================================================================
# PREFLIGHT: valida que el esquema origen es el esperado ANTES de leer nada.
# Sin esto, un cambio de nombre de columna en CNM se manifestaria como un error
# opaco de SQL a mitad de la pasada.
# =============================================================================
sub check_source_schema {
   my ($mh) = @_;
   my $sql = "SELECT table_name, column_name FROM information_schema.columns
               WHERE table_schema = ?";
   my $rows = $mh->selectall_arrayref($sql, undef, $o{'my-db'});
   my %have;
   $have{$_->[0]}{$_->[1]} = 1 for @$rows;

   my @falta;
   for my $t (sort keys %SRC_REQUIRED) {
      # information_schema solo muestra al usuario las tablas sobre las que tiene
      # SELECT, asi que "no existe" y "sin permiso" son indistinguibles desde aqui.
      unless ($have{$t}) {
         push @falta, "tabla $t (no existe, o el usuario carece de SELECT sobre ella)";
         next;
      }
      for my $c (@{$SRC_REQUIRED{$t}}) {
         push @falta, "$t.$c" unless $have{$t}{$c};
      }
   }
   if (@falta) {
      elog("el esquema de $o{'my-db'} no coincide con el esperado.");
      elog("  falta: $_") for @falta;
      elog("Ajusta \$SRC_SQL y \%SRC_REQUIRED en este script al modelo real.");
      exit 2;
   }

   # COLUMNA OPCIONAL: sem_binding_role.status la anade cnm_reconcile_schema.sql,
   # que puede no estar aplicado todavia. Si existe, se excluyen las ataduras
   # 'retired'; si no, se procesan todas. Se detecta, no se asume.
   if ($have{sem_binding_role}{status}) {
      $SRC_SQL .= "  AND b.status = 'active'\n";
      vlog("sem_binding_role.status detectada: se excluyen ataduras 'retired'");
   } else {
      vlog("sem_binding_role.status NO existe (reconcile sin aplicar): "
          ."se replican todas las ataduras");
   }

   vlog("preflight de esquema OK (".scalar(keys %SRC_REQUIRED)." tablas verificadas)");
   return 1;
}

# =============================================================================
# Lectura del origen
# =============================================================================
sub read_source {
   my ($mh, $sql, $que) = @_;
   my $rows = eval { $mh->selectall_arrayref($sql) };
   unless ($rows) { elog("fallo leyendo $que: $@"); exit 3 }
   vlog("origen leido ($que): ".scalar(@$rows)." filas");
   return $rows;
}

# Resumen del puente: cobertura y coherencia del canario, para el log y --dry-run.
sub resumen_map {
   my ($rows) = @_;
   my (%inst, $sin_dev, $sin_sub, $sin_key);
   for my $r (@$rows) {
      $inst{$r->[1]} = 1;
      $sin_dev++ unless defined $r->[2];
      $sin_sub++ unless defined $r->[3] && $r->[3] ne '';
      $sin_key++ unless defined $r->[4] && $r->[4] ne '';
   }
   my $t = sprintf("metricas=%d instancias=%d", scalar(@$rows), scalar(keys %inst));
   $t .= sprintf(" | sin iddev=%d", $sin_dev) if $sin_dev;
   $t .= sprintf(" | sin subtype=%d", $sin_sub) if $sin_sub;
   $t .= sprintf(" | sin stable_key=%d", $sin_key) if $sin_key;
   return $t;
}

# Resumen para el log y para --dry-run: permite ver de un vistazo si la foto
# tiene sentido antes de publicarla.
sub resumen {
   my ($rows) = @_;
   # indices segun @DST_COLS: 4=weight, 14=signal_class, 22=value_scale,
   # 23=capacity, 24=needs_capacity, 18=direction
   my (%cls, %inst, %rol, $sin_clase, $peso0, $sin_cap, $escala);
   for my $r (@$rows) {
      $inst{$r->[0]} = 1; $rol{$r->[1]} = 1;
      my $c = defined $r->[14] ? $r->[14] : '(sin clase)';
      $cls{$c}++;
      $sin_clase++ unless defined $r->[14];
      $peso0++   if defined $r->[4] && $r->[4] == 0;
      $sin_cap++ if $r->[24] && !defined $r->[23];
      $escala++  if defined $r->[22] && $r->[22] != 1;
   }
   my $t = sprintf("filas=%d instancias=%d roles=%d", scalar(@$rows),
                   scalar(keys %inst), scalar(keys %rol));
   $t .= sprintf(" | %s=%d", $_, $cls{$_}) for sort keys %cls;
   $t .= sprintf(" | sin signal_class=%d", $sin_clase) if $sin_clase;
   $t .= sprintf(" | weight=0 (no agregan)=%d", $peso0) if $peso0;
   $t .= sprintf(" | needs_capacity SIN capacity=%d", $sin_cap) if $sin_cap;
   $t .= sprintf(" | con value_scale<>1=%d", $escala) if $escala;
   return $t;
}

# =============================================================================
# Publicacion atomica
# =============================================================================
# Publicacion atomica generica. Se parametriza por tabla para NO duplicar las
# salvaguardas (min-rows, max-shrink, ROLLBACK) en cada replica: una sola
# implementacion probada, usada por las dos tablas.
sub publish {
   my ($ph, $tabla, $cols_ref, $rows, $min_rows) = @_;

   # Cuantas filas hay publicadas ahora: base de la salvaguarda de encogimiento.
   my $prev = 0;
   eval { ($prev) = $ph->selectrow_array("SELECT count(*) FROM $tabla"); 1 }
      or do { $ph->rollback; elog("no existe $tabla: crea antes el DDL "
                                 ."(sem_role_lookup.sql)"); exit 4 };

   my $n = scalar @$rows;
   if ($n < $min_rows) {
      $ph->rollback;
      elog("[$tabla] el origen devolvio $n filas (< $min_rows). "
          ."NO se publica; se conserva la replica anterior ($prev filas).");
      exit 5;
   }
   if ($prev > 0) {
      my $shrink = 100*($prev-$n)/$prev;
      if ($shrink > $o{'max-shrink-pct'}) {
         $ph->rollback;
         elog(sprintf("[$tabla] el origen encogio un %.1f%% (%d -> %d), mas de "
             ."--max-shrink-pct=%d%%. NO se publica; se conserva la replica "
             ."anterior. Si el encogimiento es legitimo, relanza con "
             ."--max-shrink-pct mayor.", $shrink, $prev, $n, $o{'max-shrink-pct'}));
         exit 5;
      }
   }

   my $ok = eval {
      # TRUNCATE + COPY dentro de la MISMA transaccion: los lectores no ven
      # jamas una tabla a medias. Decimas de segundo con estos volumenes.
      $ph->do("TRUNCATE $tabla");
      my $cols = join(',', @$cols_ref);
      $ph->do("COPY $tabla ($cols) FROM STDIN WITH (FORMAT csv, NULL '')");
      for my $r (@$rows) {
         $ph->pg_putcopydata(join(',', map { csv_field($_) } @$r)."\n");
      }
      $ph->pg_putcopyend();
      $ph->commit;
      1;
   };
   unless ($ok) {
      my $e = $@ || 'desconocido';
      eval { $ph->rollback };
      elog("[$tabla] fallo publicando (ROLLBACK hecho, replica anterior intacta): $e");
      exit 4;
   }
   return ($prev, $n);
}

# Escapado CSV para COPY. NULL se representa como campo vacio sin comillas,
# acorde con NULL '' del COPY. Los booleanos de MySQL (0/1) los interpreta
# PostgreSQL correctamente en una columna boolean.
sub csv_field {
   my ($v) = @_;
   return '' unless defined $v;
   $v =~ s/\r?\n/ /g;
   if ($v =~ /[",]/) { $v =~ s/"/""/g; return '"'.$v.'"' }
   return $v;
}

# =============================================================================
# MAIN
# =============================================================================
my $mh = connect_mysql();
check_source_schema($mh);
if ($o{'check-schema'}) { print "Esquema origen OK\n"; $mh->disconnect; exit 0 }

build_map_sql($mh);
my $rows = read_source($mh, $SRC_SQL, 'capa semantica');
my $maps = read_source($mh, $MAP_SQL, 'puente id_metric->instancia');
$mh->disconnect;

my $res  = resumen($rows);
my $resm = resumen_map($maps);
vlog("roles: $res");
vlog("mapa:  $resm");

if ($o{'dry-run'}) {
   print ts()." [sync] DRY-RUN, no se escribe nada\n";
   print ts()." [sync] roles: $res\n";
   print ts()." [sync] mapa:  $resm\n";
   exit 0;
}

my $ph = connect_pg();

# Las dos publicaciones son transacciones INDEPENDIENTES. Si la segunda fallara,
# la primera queda publicada: no hay estado intermedio incoherente, porque cada
# tabla es autonoma y las vistas que las cruzan toleran filas sin pareja
# (LEFT JOIN) mostrandolas como deuda de cobertura.
my ($prev,  $n)  = publish($ph, 'sem_role_lookup', \@DST_COLS, $rows, $o{'min-rows'});
my ($prevm, $nm) = publish($ph, 'sem_metric_map',  \@MAP_COLS, $maps, $o{'min-rows'});
$ph->disconnect;

print ts()." [sync] roles: $prev -> $n filas | $res\n";
print ts()." [sync] mapa:  $prevm -> $nm filas | $resm\n";
exit 0;
