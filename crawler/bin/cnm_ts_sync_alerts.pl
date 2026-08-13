#!/usr/bin/perl -w
#--------------------------------------------------------------------------------------
# NAME: cnm_ts_sync_alerts.pl
#
# DESCRIPTION:
# Replica las alertas de CNM (MariaDB, base onm) al servidor analitico
# (PostgreSQL/Timescale):
#   - alerts_store  -> cnm_alerts_store   INCREMENTAL (marca de agua date_store)
#   - alerts        -> cnm_alerts_open    REEMPLAZO COMPLETO (~455 filas)
#
# MOTIVO: CNM purga alerts_store POR NUMERO DE FILAS. Medido: ~3.886 filas/dia
# sobre ~579.000 en tabla -> retencion efectiva de 5-7 meses (2024 y 2025 ya
# estan a cero). Cada mes sin replicar es historico perdido sin retorno.
#
# ALCANCE DELIBERADAMENTE ESTRECHO: esto SOLO captura. No calcula salud, no
# interpreta severidad, no filtra por tipo. Capturar ANCHO, interpretar ESTRECHO.
#
# SOBRE CNM SOLO HACE SELECT. No escribe, no bloquea, no crea nada.
# NO TOCA la hipertabla series: no aparece en ninguna sentencia de este script.
#
# CALLING SAMPLE:
# cnm_ts_sync_alerts.pl --pg-host 10.x.x.x --pg-db obs --pg-user u --pg-pass p \
#                        --my-user u --my-pass p
# cnm_ts_sync_alerts.pl ... --dry-run -v            (lee y resume, no escribe)
# cnm_ts_sync_alerts.pl ... --since 2026-01-01      (recarga desde una fecha)
# cnm_ts_sync_alerts.pl ... --full                  (ignora marca de agua)
# cnm_ts_sync_alerts.pl ... --with-open             (ademas, las alertas en curso)
# cnm_ts_sync_alerts.pl ... --only-open             (SOLO las alertas en curso)
#
# EXIT CODE:
#  0: OK (o dry-run correcto)
#  1: error de argumentos
#  2: las tablas destino no existen (ejecutar antes cnm_alerts_replica.sql)
#  3: error de conexion o lectura en MariaDB
#  4: error de escritura en PostgreSQL (con ROLLBACK; la replica queda intacta)
#
# PROGRAMACION: timer de systemd cada hora. Con 5-7 meses de margen de purga,
# una hora de desfase es holgadisima; la frecuencia es por frescura, no por
# riesgo de perdida.
#--------------------------------------------------------------------------------------
use strict;
use warnings;
use DBI;
use Getopt::Long;
use POSIX qw(strftime);
use Encode qw(decode encode);

my $USAGE = <<'EOT';
cnm_ts_sync_alerts.pl --pg-host H --pg-db D --pg-user U --pg-pass P [opciones]
  --pg-host/--pg-port/--pg-db/--pg-user/--pg-pass  destino PostgreSQL
  --my-db            base MariaDB origen (por defecto onm)
  --my-host          host MariaDB (por defecto localhost)
  --my-user/--my-pass credencial de MariaDB
  --overlap N        segundos de solape sobre la marca de agua (def. 3600)
  --since FECHA      recarga desde 'YYYY-MM-DD' (ignora la marca de agua)
  --full             recarga TODO el origen (ignora la marca de agua)
  --only-open        SOLO las alertas en curso; NO toca el historico. Pensado para
                     ejecucion frecuente (cada 5 min): 'alerts' son ~460 filas y su
                     lectura es de milisegundos, mientras que el incremental del
                     historico recorre 579.000 filas (~1,8 s) porque date_store no
                     esta indexada. Mezclarlos en una ejecucion cada 5 minutos
                     costaria 8,6 min/dia de CPU en CNM en vez de 1,8 s/dia.
  --with-open        ADEMAS, sincroniza las alertas en curso (alerts -> cnm_alerts_open).
                     POR DEFECTO NO se sincronizan: el historico (alerts_store) es lo
                     que CNM purga y lo unico que corre riesgo de perderse. La foto de
                     alertas abiertas se puede empezar a capturar cuando se decida la
                     politica de alertas persistentes no reconocidas.
  --batch N          filas por lote de COPY (def. 20000)
  --dry-run          lee y resume, pero NO escribe
  -v                 verboso
EOT

my %o = ( 'pg-host'=>'127.0.0.1', 'pg-port'=>5432, 'pg-db'=>undef,
          'pg-user'=>undef, 'pg-pass'=>undef,
          'my-db'=>'onm', 'my-host'=>'localhost',
          'my-user'=>undef, 'my-pass'=>undef,
          overlap=>3600, since=>undef, full=>0, 'with-open'=>0, 'only-open'=>0,
          batch=>20000, 'dry-run'=>0, verbose=>0 );
GetOptions(\%o, 'pg-host=s','pg-port=i','pg-db=s','pg-user=s','pg-pass=s',
                'my-db=s','my-host=s','my-user=s','my-pass=s',
                'overlap=i','since=s','full!','with-open!','only-open!','batch=i',
                'dry-run!','verbose|v!','help|h')
   or die $USAGE;
die $USAGE if $o{help};
die $USAGE unless $o{'pg-db'} && $o{'pg-user'};

sub ts   { strftime("%Y-%m-%d %H:%M:%S", localtime) }
sub vlog { print ts()." [alerts] $_[0]\n" if $o{verbose} }
sub ilog { print ts()." [alerts] $_[0]\n" }
sub elog { print STDERR ts()." [alerts] ERROR: $_[0]\n" }

# =============================================================================
# COLUMNAS
#
# name/ip: nombre e IP del dispositivo. Se replican porque son imprescindibles
# para contrastar un resultado contra la consola de CNM sin tener que cruzar a
# mano con la tabla devices.
#
# Se descartan a proposito: bdata (mediumblob sin uso analitico), notes,
# ticket_descr, correlated_by, domain, ip, cid_ip, note_id, id_note_type,
# id_store, id_ticket. No aportan a salud por rol y engordan la replica.
#
# Se CONSERVA event_data: contiene la expresion que disparo la alerta
# (**ALERT (v1>92) (94 > 92)**), imprescindible para la validacion cruzada
# contra series.
# =============================================================================
my @STORE_SRC = qw(id_alert id_device id_metric id_alert_type watch severity
                   duration date date_store date_last counter type subtype
                   mname label cause ack mnt event_data name ip);
my @STORE_DST = qw(id_alert id_device id_metric id_alert_type watch severity
                   duration date_epoch date_store_epoch date_last_epoch counter
                   type subtype mname label cause ack mnt event_data
                   dev_name dev_ip);

my @OPEN_SRC  = qw(id_alert id_device id_metric id_alert_type watch severity
                   date date_last counter ack notif critic type subtype mname
                   label cause mode cid event_data name ip);
my @OPEN_DST  = qw(id_alert id_device id_metric id_alert_type watch severity
                   date_epoch date_last_epoch counter ack notif critic type
                   subtype mname label cause mode cid event_data
                   dev_name dev_ip);

# =============================================================================
# Conexiones
# =============================================================================
sub connect_mysql {
   # CONVENCION DE CREDENCIALES: misma que cnm_ts_loader.pl, por linea de
   # comandos. Es deliberado NO usar aqui un mecanismo distinto (fichero de
   # opciones, variables de entorno): tener dos formas de configurar lo mismo
   # complica la operacion. Si en el futuro se decide sacar las credenciales de
   # la linea de comandos, el cambio se hace en TODOS los scripts a la vez.
   my $dsn = "dbi:mysql:database=$o{'my-db'};host=$o{'my-host'}";
   my $h = eval { DBI->connect($dsn, $o{'my-user'}, $o{'my-pass'},
             { RaiseError=>1, PrintError=>0, AutoCommit=>1,
               mysql_connect_timeout=>15,
               # mysql_enable_utf8 DESACTIVADO A PROPOSITO. Con el activado, el
               # driver devuelve cadenas de CARACTERES; al escribirlas luego en
               # el COPY se vuelven a codificar y el texto sale doblemente
               # codificado ("configuracion" -> "configuraciA^3n"). Verificado en
               # pruebas. Como las columnas de texto de CNM ya estan en utf8
               # (documentacion_producto.md §7) y PostgreSQL espera utf8, lo
               # correcto es NO convertir: pasar los bytes tal cual y limitarse
               # a VALIDARLOS (ver clean_text).
               mysql_enable_utf8 => 0 }) };
   unless ($h) { elog("no puedo conectar a MariaDB ($o{'my-db'}\@$o{'my-host'}): $@"); exit 3 }
   eval { $h->do("SET NAMES utf8") };
   # MySQL 5.5: con mysql_use_result (streaming) el servidor va enviando filas a
   # medida que el cliente las consume. Como aqui cada fila se reenvia por COPY a
   # PostgreSQL, si la red o el destino se atascan mas de net_write_timeout
   # (60 s por defecto) el servidor ABORTA el envio a mitad del volcado. Se sube
   # solo para esta sesion; no altera la configuracion del servidor.
   eval { $h->do("SET SESSION net_write_timeout = 600") };
   eval { $h->do("SET SESSION net_read_timeout  = 600") };
   return $h;
}

sub connect_pg {
   my $dsn = "dbi:Pg:host=$o{'pg-host'};port=$o{'pg-port'};dbname=$o{'pg-db'}";
   my $h = eval { DBI->connect($dsn, $o{'pg-user'}, $o{'pg-pass'},
             # pg_enable_utf8=0: DBD::Pg trata las cadenas como BYTES y las envia
             # tal cual. Es lo que queremos, porque clean_text ya garantiza que
             # son UTF-8 valido. Con =1 el driver recodificaria (doble conversion).
             { RaiseError=>1, PrintError=>0, AutoCommit=>0, pg_enable_utf8=>0 }) };
   unless ($h) { elog("no puedo conectar a PostgreSQL: $@"); exit 4 }
   return $h;
}

# =============================================================================
# PREFLIGHT: las tablas destino DEBEN existir. El script no crea DDL: si falta
# algo, es un despliegue incompleto y hay que resolverlo a mano, no improvisando
# estructuras en produccion.
# =============================================================================
sub check_target {
   my ($ph) = @_;
   # Solo se exige la tabla que se va a usar.
   my @req = $o{'only-open'} ? () : ('cnm_alerts_store');
   push @req, 'cnm_alerts_open' if $o{'with-open'};
   for my $t (@req) {
      my ($ok) = eval { $ph->selectrow_array("SELECT to_regclass(?)", undef, $t) };
      unless ($ok) {
         $ph->rollback;
         elog("no existe la tabla $t en la base $o{'pg-db'}.");
         elog("Ejecuta primero: psql -d $o{'pg-db'} -f cnm_alerts_replica.sql");
         exit 2;
      }
   }
   vlog("preflight destino OK");
}

# =============================================================================
# Saneado de texto
#
# Dos peligros reales al pasar de MariaDB a PostgreSQL:
#  a. bytes que no forman UTF-8 valido -> PostgreSQL aborta el COPY completo,
#     tumbando un lote entero por una sola fila.
#  b. NUL (\0) -> PostgreSQL NO admite \0 en columnas text, ni escapado.
# Se limpia por fila en vez de arriesgar el lote.
# =============================================================================
sub clean_text {
   my ($v) = @_;
   return undef unless defined $v;
   $v =~ s/\0//g;                                  # NUL: prohibido en text

   if (utf8::is_utf8($v)) {
      # El driver devolvio caracteres (no deberia, con mysql_enable_utf8=0):
      # se pasa a bytes UTF-8 explicitamente, una sola vez.
      return encode('UTF-8', $v);
   }
   # Bytes. Se VALIDAN sin transformarlos: si ya son UTF-8 correcto (el caso
   # normal), se devuelven intactos. Solo si hay secuencias invalidas se hace
   # una pasada con perdida, sustituyendolas por U+FFFD; asi una sola fila
   # corrupta no aborta el COPY de todo el lote.
   #
   # OJO CON LEAVE_SRC: Encode::decode/encode CONSUMEN (vacian) la cadena origen
   # cuando CHECK != 0, salvo que se le pase LEAVE_SRC. Sin el, esta validacion
   # blanquearia justo el dato que pretende validar. Detectado en pruebas.
   return $v if eval { decode('UTF-8', $v, Encode::FB_CROAK | Encode::LEAVE_SRC); 1 };
   return encode('UTF-8', decode('UTF-8', $v, Encode::FB_DEFAULT | Encode::LEAVE_SRC));
}

# Escapado CSV para COPY ... WITH (FORMAT csv, NULL '').
# Los saltos de linea SI se conservan: PostgreSQL los admite dentro de campos
# entrecomillados, y event_data puede contenerlos de forma legitima.
sub csv_field {
   my ($v) = @_;
   return '' unless defined $v;
   if ($v =~ /["\n\r,]/) { $v =~ s/"/""/g; return '"'.$v.'"' }
   return $v;
}

# =============================================================================
# Marca de agua
#
# POR QUE date_store Y NO id_alert: aunque id_alert sea PK autoincremental, una
# alerta abierta hace meses tiene id BAJO y solo llega a alerts_store HOY, al
# cerrarse. Sincronizar por MAX(id_alert) perderia silenciosamente justo las
# alertas mas largas, que son las que mas pesan en el uptime. date_store es el
# instante de archivado: monotono por definicion.
#
# El solape (--overlap) cubre filas archivadas en el mismo segundo que quedaron
# a caballo entre dos pasadas. Es gratis: ON CONFLICT DO NOTHING las descarta.
# =============================================================================
sub watermark {
   my ($ph) = @_;
   return (0, 'carga completa (--full)') if $o{full};
   if ($o{since}) {
      my ($e) = $ph->selectrow_array("SELECT EXTRACT(epoch FROM ?::timestamptz)::bigint",
                                     undef, $o{since});
      return ($e, "desde --since $o{since}");
   }
   my ($max) = $ph->selectrow_array("SELECT max(date_store_epoch) FROM cnm_alerts_store");
   return (0, 'primera carga (replica vacia)') unless defined $max;
   my $desde = $max - $o{overlap};
   return ($desde, "incremental desde marca de agua ".scalar(localtime($max))
                   ." menos $o{overlap}s de solape");
}

# =============================================================================
# Sincronizacion del HISTORICO (incremental)
#
# Se lee en STREAMING (mysql_use_result): las filas se procesan una a una en vez
# de materializar cientos de miles en memoria. La primera carga son ~579.000
# filas con event_data de varios cientos de bytes; traerlas todas de golpe seria
# innecesariamente agresivo con la RAM del host de CNM.
# =============================================================================
sub sync_store {
   my ($mh, $ph) = @_;

   my ($desde, $motivo) = $o{'dry-run'} ? (0,'dry-run: sin marca de agua') : watermark($ph);
   ilog("historico: $motivo");

   my $prev = 0;
   unless ($o{'dry-run'}) {
      ($prev) = $ph->selectrow_array("SELECT count(*) FROM cnm_alerts_store");
   }

   my $cols = join(',', @STORE_SRC);
   # SIN ORDER BY a proposito. date_store NO esta indexada, asi que ordenar
   # obligaria a MySQL 5.5 a materializar y hacer filesort de ~579.000 filas ANTES
   # de empezar a enviar, con tabla temporal en disco. El orden no aporta nada:
   # todo va en UNA transaccion (o entra el lote entero o no entra ninguno), la
   # marca de agua se recalcula despues como MAX(date_store_epoch) y los duplicados
   # los descarta ON CONFLICT DO NOTHING.
   my $sql  = "SELECT $cols FROM alerts_store WHERE date_store >= ?";
   my $sth  = eval {
      my $s = $mh->prepare($sql, { mysql_use_result => 1 });   # streaming
      $s->execute($desde); $s;
   };
   unless ($sth) { elog("fallo leyendo alerts_store: $@"); exit 3 }

   my ($leidas, $lote, @buf) = (0, 0);
   my %por_tipo;
   my $copy_abierto = 0;

   my $abrir_copy = sub {
      return if $o{'dry-run'} || $copy_abierto;
      $ph->do("CREATE TEMP TABLE stg_store (LIKE cnm_alerts_store INCLUDING DEFAULTS "
             ."EXCLUDING GENERATED) ON COMMIT DROP");
      $ph->do("COPY stg_store (".join(',',@STORE_DST).") FROM STDIN "
             ."WITH (FORMAT csv, NULL '')");
      $copy_abierto = 1;
   };

   while (my @r = $sth->fetchrow_array) {
      $leidas++;
      $por_tipo{ defined $r[11] ? $r[11] : '(sin tipo)' }++;
      next if $o{'dry-run'};
      $abrir_copy->();
      # Se sanea TODO el registro, no una lista de indices: si alguien reordena
      # @STORE_SRC, unos indices fijos apuntarian a columnas equivocadas en
      # silencio. Sobre numeros clean_text es inocuo.
      $ph->pg_putcopydata(join(',', map { csv_field(clean_text($_)) } @r)."\n");
   }
   $sth->finish;

   if ($o{'dry-run'}) {
      ilog("DRY-RUN historico: $leidas filas leidas, no se escribe nada");
      ilog("  por tipo: ".join(' | ', map {"$_=$por_tipo{$_}"} sort keys %por_tipo))
         if %por_tipo;
      return (0, 0);
   }

   unless ($copy_abierto) { ilog("historico: 0 filas nuevas"); return ($prev, 0) }

   my $insertadas = 0;
   my $ok = eval {
      $ph->pg_putcopyend();
      # ON CONFLICT DO NOTHING: las filas archivadas no cambian en origen, y el
      # solape reintroduce a proposito algunas ya replicadas.
      my $c = join(',', @STORE_DST);
      $insertadas = $ph->do("INSERT INTO cnm_alerts_store ($c) SELECT $c FROM stg_store "
                           ."ON CONFLICT (id_alert) DO NOTHING");
      $ph->commit;
      1;
   };
   unless ($ok) {
      my $e = $@ || 'desconocido'; $e =~ s/\s+/ /g;
      eval { $ph->rollback };
      elog("fallo publicando el historico (ROLLBACK; replica intacta): ".substr($e,0,300));
      exit 4;
   }
   $insertadas = 0 if $insertadas eq '0E0';
   my ($ahora) = $ph->selectrow_array("SELECT count(*) FROM cnm_alerts_store");
   $ph->commit;

   ilog("historico: $leidas leidas | $insertadas nuevas | ".($leidas-$insertadas)
       ." ya presentes | total replica: $prev -> $ahora");
   vlog("  por tipo: ".join(' | ', map {"$_=$por_tipo{$_}"} sort keys %por_tipo));
   return ($ahora, $insertadas);
}

# =============================================================================
# Sincronizacion de las ALERTAS EN CURSO (reemplazo completo)
#
# Son ~455 filas y representan una FOTO del momento, no un historico: acumularlas
# no tendria sentido. TRUNCATE + COPY dentro de la MISMA transaccion, de modo que
# ningun lector ve nunca la tabla a medias.
# =============================================================================
sub sync_open {
   my ($mh, $ph) = @_;

   my $cols = join(',', @OPEN_SRC);
   my $rows = eval { $mh->selectall_arrayref("SELECT $cols FROM alerts") };
   unless ($rows) { elog("fallo leyendo alerts: $@"); exit 3 }
   my $n = scalar @$rows;

   if ($o{'dry-run'}) { ilog("DRY-RUN abiertas: $n filas leidas, no se escribe"); return $n }

   # Salvaguarda: si el origen devuelve 0 filas es mas probable un fallo de
   # lectura que un CNM sin ninguna alerta abierta. No se vacia la replica.
   if ($n == 0) {
      my ($prev) = $ph->selectrow_array("SELECT count(*) FROM cnm_alerts_open");
      $ph->rollback;
      ilog("abiertas: el origen devolvio 0 filas; NO se vacia la replica "
          ."(se conservan $prev). Si CNM esta realmente sin alertas, forzar a mano.");
      return 0;
   }

   my $ok = eval {
      $ph->do("TRUNCATE cnm_alerts_open");
      $ph->do("COPY cnm_alerts_open (".join(',',@OPEN_DST).") FROM STDIN "
             ."WITH (FORMAT csv, NULL '')");
      for my $r (@$rows) {
         $ph->pg_putcopydata(join(',', map { csv_field(clean_text($_)) } @$r)."\n");
      }
      $ph->pg_putcopyend();
      $ph->commit;
      1;
   };
   unless ($ok) {
      my $e = $@ || 'desconocido'; $e =~ s/\s+/ /g;
      eval { $ph->rollback };
      elog("fallo publicando las abiertas (ROLLBACK; replica intacta): ".substr($e,0,300));
      exit 4;
   }
   ilog("abiertas: $n filas replicadas");
   return $n;
}

# =============================================================================
# MAIN
# =============================================================================
$o{'with-open'} = 1 if $o{'only-open'};   # --only-open implica sincronizarlas

my $mh = connect_mysql();
my $ph = connect_pg();
check_target($ph) unless $o{'dry-run'};

if ($o{'only-open'}) {
   vlog("modo --only-open: se omite el historico (alerts_store)");
} else {
   my ($total, $nuevas) = sync_store($mh, $ph);
}
if ($o{'with-open'}) { sync_open($mh, $ph) }
else { vlog("alertas en curso: omitidas (usar --with-open para incluirlas)") }

$mh->disconnect;
$ph->disconnect;
exit 0;
