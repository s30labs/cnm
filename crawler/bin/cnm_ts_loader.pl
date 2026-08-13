#!/usr/bin/perl
# =============================================================================
# cnm_ts_loader.pl — lee ficheros del *spool* y los carga en TimescaleDB.
#
# TOPOLOGIA A: corre en el HOST DE CNM; lee el spool local y hace COPY al
# Postgres/Timescale REMOTO (--pg-host <ip>). Desacoplado de los crawlers.
#
# PROTECCION DEL DISCO DE CNM (prioridad absoluta):
#   - El crawler (Crawler::Spool) aplica BACKPRESSURE: deja de volcar al spool
#     si ready/ supera ~3h de antiguedad -> el spool tiene un TECHO.
#   - Este loader: (a) borra en exito; (b) si Timescale esta caido, NO pierde
#     ficheros: los devuelve a ready/ (buffer) y reintenta; (c) acota error/;
#     (d) watchdog de espacio libre (avisa fuerte, es el disco de CNM).
#
# DISTINCION CLAVE ante un fallo de lote:
#   - conexion caida  -> los ficheros VUELVEN a ready/ (no es culpa del dato).
#   - error de datos  -> a error/ (acotado). Nunca se llena el disco por esto.
#
# CICLO: claim (rename ready->processing/<pid>) -> COPY a staging ->
#   INSERT ... ON CONFLICT DO NOTHING (idempotente) -> COMMIT -> borrar (o
#   --archive a done/). Varios loaders en paralelo son seguros (claim por rename).
#
# HOOKS: colapso de estados one-hot (§4.9, requiere sem_state_dict) ACTIVO.
#   sem_instance_id en carga (§4.5) ACTIVO desde el Hito 01 de la capa semantica:
#   su insumo (sem_metric_binding en MariaDB) ya existe. Ver seccion MAPA.
#
# USO:
#   perl cnm_ts_loader.pl --pg-host 10.x.x.x --pg-db obs --pg-user u --pg-pass p \
#        [--spool /opt/data/spool/ts] [--interval 15] [--batch 200] \
#        [--min-free-mb 500] [--max-error-files 1000] [--archive] [--once] [-v] \
#        [--my-db onm] [--my-host localhost] [--my-user u] [--my-pass p] \
#        [--map-refresh 3600] [--no-map]
#
# LOG: usa Logger.pm del motor de CNM -> SYSLOG (facility local0, la misma que
#      los crawlers). La rotacion la gestiona el sistema: no hay fichero propio
#      que mantener. Con -v ademas se imprime el detalle por STDERR (ejecucion
#      manual). Si Logger no esta disponible, se degrada a STDERR.
# =============================================================================
use strict;
use warnings;
use DBI;
use Getopt::Long;
use File::Path qw(make_path);
use File::Basename;
use POSIX qw(strftime);

my %o=( spool=>'/opt/data/spool/ts', 'pg-host'=>'127.0.0.1','pg-port'=>5432,
        'pg-db'=>undef,'pg-user'=>undef,'pg-pass'=>undef,
        batch=>200, interval=>15, once=>0, archive=>0,
        'min-free-mb'=>500, 'max-error-files'=>1000, verbose=>0,
        # --- MariaDB local (mapa id_metric -> sem_instance_id) ---
        # Credencial por linea de comandos, igual que --pg-user/--pg-pass: se
        # mantiene UNA sola convencion en todos los scripts del proyecto.
        'my-db'=>'onm', 'my-host'=>'localhost',
        'my-user'=>undef, 'my-pass'=>undef,
        'map-refresh'=>3600, 'no-map'=>0 );
GetOptions(\%o,
   'spool=s','pg-host=s','pg-port=i','pg-db=s','pg-user=s','pg-pass=s',
   'batch=i','interval=i','once!','archive!',
   'min-free-mb=i','max-error-files=i','verbose|v!',
   'my-db=s','my-host=s','my-user=s','my-pass=s','map-refresh=i','no-map!') or die "Argumentos invalidos\n";

# --- LOG: se usa la infraestructura del motor de CNM (Logger.pm -> syslog) ---
# Ventaja: la rotacion la gestiona el sistema (rsyslog/logrotate), no hay que
# mantener un fichero propio, y los mensajes quedan junto a los del motor.
# Logger usa basename($0) como ident y la facility local0 (la misma que los
# crawlers). Si el modulo no esta disponible (ejecucion fuera del appliance),
# se degrada a STDERR sin romper nada.
my $USE_LOGGER = 0;
BEGIN { unshift @INC, '/opt/cnm/crawler/bin'; }
eval {
   require Logger;
   Logger->import();
   Logger::init_log();
   $USE_LOGGER = 1;
};
die "Falta --pg-db\n" unless $o{'pg-db'};

my $READY=$o{spool}.'/ready';
my $PROC =$o{spool}.'/processing/'.$$;
my $DONE =$o{spool}.'/done';
my $ERR  =$o{spool}.'/error';
make_path($_) for ($READY,$PROC,$ERR);
make_path($DONE) if $o{archive};

my $LAST_ERR = '';
# los errores se registran SIEMPRE (no dependen de -v): sin esto, una cuarentena
# masiva ocurre en silencio y no hay forma de saber por que.
sub ts_now { return strftime('%H:%M:%S', localtime); }

# emite un mensaje: a syslog (Logger) si esta disponible y, ademas, a STDERR
# cuando se ejecuta a mano con -v (util para depurar en el terminal).
sub emit {
   my ($nivel,$msg)=@_;
   if ($USE_LOGGER) {
      if    ($nivel eq 'err')  { Logger::log_warn($msg);   }
      elsif ($nivel eq 'warn') { Logger::log_warn($msg);   }
      else                     { Logger::log_notice($msg); }
   }
   if (!$USE_LOGGER || $o{verbose}) {
      print STDERR "[".ts_now()."] [".uc($nivel)."] $msg\n";
   }
}
sub log_err { emit('err', join('',@_)); }
# detalle por lote: solo interesa en ejecucion manual (-v); no ensucia syslog.
sub vlog { print STDERR "[".ts_now()."] ".join('',@_)."\n" if $o{verbose}; }
sub iso  { my $t=shift; return strftime('%Y-%m-%d %H:%M:%S+00', gmtime($t)); }
# escapa un campo de texto para COPY CSV (vacio -> NULL por la opcion NULL '')
sub csv_field {
   my ($s)=@_;
   return '' unless defined $s && $s ne '';
   if ($s =~ /[",\n\r]/) { $s =~ s/"/""/g; return '"'.$s.'"'; }
   return $s;
}

# aviso como maximo 1 vez cada 5 min (evita spam de logs)
my %last_warn;
sub warn_throttled {
   my ($key,$msg)=@_;
   my $now=time;
   if (!$last_warn{$key} || ($now-$last_warn{$key})>300) {
      emit('warn',$msg);
      $last_warn{$key}=$now;
   }
}

my $dsn="dbi:Pg:dbname=$o{'pg-db'};host=$o{'pg-host'};port=$o{'pg-port'}";
sub try_connect {
   my $dbh = eval { DBI->connect($dsn,$o{'pg-user'},$o{'pg-pass'},
      {RaiseError=>1,PrintError=>0,AutoCommit=>0}) };
   no warnings 'once';
   return ($dbh, $dbh ? '' : ($@ || $DBI::errstr || 'sin detalle'));
}
# preflight: el colapso one-hot (§4.9) consulta sem_state_dict en CADA carga.
#   Si la tabla no existe, TODAS las transacciones fallan y —antes del aislamiento
#   fichero a fichero— eso mandaba lotes enteros a cuarentena. Se comprueba una
#   sola vez por conexion y se avisa de forma inequivoca.
my $PREFLIGHT_OK = 0;
sub preflight {
   my ($dbh)=@_;
   return 1 if $PREFLIGHT_OK;
   my $faltan = 0;
   for my $tabla (qw(series sem_state_dict)) {
      my $existe = eval {
         my $s=$dbh->prepare("SELECT to_regclass(?) IS NOT NULL");
         $s->execute($tabla);
         my ($r)=$s->fetchrow_array; $s->finish; $r ? 1 : 0;
      };
      if (!defined $existe) { log_err("preflight: no puedo comprobar '$tabla' ($@)"); return 0; }
      unless ($existe) {
         $faltan++;
         if ($tabla eq 'sem_state_dict') {
            log_err("FALTA la tabla '$tabla' en la BD: el colapso one-hot fallara en TODAS las cargas. "
                   ."Cargarla con:  psql -d <bd> -f cnm_state_dict.sql");
         } else {
            log_err("FALTA la tabla '$tabla' en la BD: aplicar el esquema (ts_schema.sql).");
         }
      }
   }
   eval { $dbh->rollback };          # la comprobacion abrio transaccion
   return 0 if $faltan;
   $PREFLIGHT_OK = 1;
   vlog("preflight OK: series y sem_state_dict presentes");
   return 1;
}

sub alive { my ($dbh)=@_; return 0 unless $dbh; my $r=eval { $dbh->ping }; return $r?1:0; }

# =============================================================================
# MAPA id_metric -> sem_instance_id  (hook §4.5, activado tras el Hito 01)
#
# POR QUE SE RESUELVE EN LA INGESTA Y NO CON UN UPDATE POSTERIOR:
#   series tiene politica de compresion (columnstore a los 7 dias). Un UPDATE
#   sobre un chunk comprimido obliga a descomprimirlo: caro y desaconsejado.
#   Se escribe UNA sola vez, en el momento de insertar.
#
# POR QUE SOLO LA IDENTIDAD Y NO EL ROL:
#   instance_id es FACTUAL y estable (Trabajo A del modelo semantico). El rol es
#   JUICIO revisable (Trabajo B): si se horneara aqui, la historia quedaria
#   congelada con el rol del dia de la ingesta y una correccion posterior del
#   binding no se veria hacia atras. El rol se resuelve EN CONSULTA, contra el
#   crosswalk. Misma separacion que en CNM entre mirror y binding.
#
# POR QUE SIN FILTRO valid_to:
#   la PK de sem_metric_binding es idmetric a secas -> hay como mucho UNA fila
#   por metrica, y siempre refleja su instancia actual. Incluir las 'stale'
#   permite enriquecer muestras en vuelo de metricas recien caducadas, sin
#   ambiguedad posible. (Verificado: 0 idmetric duplicados entre vigentes.)
#
# FAIL-SAFE (a diferencia del preflight de sem_state_dict, que SI bloquea):
#   si MariaDB no responde se CONSERVA el mapa anterior y se sigue cargando. La
#   falta de mapa degrada el enriquecimiento (sem_instance_id -> NULL), no
#   corrompe el dato ni manda ficheros a cuarentena: no debe parar la ingesta.
# =============================================================================
my %IMAP;              # id_metric => instance_id
my $IMAP_TS = 0;       # epoch del ultimo refresco con exito
my $IMAP_N  = 0;       # entradas del mapa vigente

sub refresh_instance_map {
   my ($force)=@_;
   return if $o{'no-map'};
   return if !$force && $IMAP_TS && (time-$IMAP_TS) < $o{'map-refresh'};

   my $dsn = "dbi:mysql:database=$o{'my-db'};host=$o{'my-host'}";

   my %nuevo;
   my $ok = eval {
      my $mh = DBI->connect($dsn, $o{'my-user'}, $o{'my-pass'},
                 {RaiseError=>1, PrintError=>0, AutoCommit=>1, mysql_connect_timeout=>10});
      my $s = $mh->prepare("SELECT idmetric, instance_id FROM sem_metric_binding");
      $s->execute;
      while (my ($m,$i) = $s->fetchrow_array) {
         next unless defined $m && defined $i;
         $nuevo{$m+0} = $i+0;
      }
      $s->finish; $mh->disconnect;
      1;
   };
   # un mapa vacio se trata como fallo: es mas probable un problema de permisos
   # o de base equivocada que un CNM sin ninguna metrica mapeada.
   if (!$ok || !keys %nuevo) {
      my $e = $@ || 'consulta sin filas'; $e =~ s/\s+/ /g; $e = substr($e,0,200);
      warn_throttled('imap',
         "no puedo refrescar el mapa id_metric->sem_instance_id ($e); "
         .($IMAP_N ? "se conserva el anterior ($IMAP_N entradas, ".int((time-$IMAP_TS)/60)." min de antiguedad)"
                   : "se carga SIN sem_instance_id hasta que MariaDB responda"));
      return 0;
   }
   %IMAP = %nuevo; $IMAP_TS = time; $IMAP_N = scalar keys %IMAP;
   vlog("mapa id_metric->sem_instance_id refrescado: $IMAP_N entradas");
   return 1;
}

# is_conn_error: ¿el fallo es de CONEXION (culpa del entorno) o de DATOS (culpa
#   del fichero)? De esta distincion depende que los ficheros vuelvan a ready/
#   (reintento, sin perdida) o vayan a error/ (cuarentena).
#
#   NO basta con ping(): si Timescale cae EN MITAD de una transaccion, DBD::Pg
#   puede seguir devolviendo ping OK sobre una conexion ya rota, y el lote se
#   mandaba a cuarentena por error (incidencia real observada: 63 ficheros sanos
#   en error/ tras una caida de PostgreSQL).
#
#   Doble comprobacion: (1) firma del mensaje de error; (2) consulta real.
sub is_conn_error {
   my ($dbh,$err)=@_;
   $err = '' unless defined $err;
   # firmas de fallo de CONEXION (lista literal: nada de /x, que se come los espacios)
   my @SIGNS = (
      'could not connect',
      'connection refused',
      'server closed the connection',
      'connection not open',
      'no connection to the server',
      'terminating connection',
      'could not send data',
      'could not receive data',
      'server has gone away',
      'SSL connection has been closed',
      'connection timed out',
      'administrator command',
      'database system is shutting down',
      'the database system is starting up',
   );
   for my $s (@SIGNS) { return 1 if index(lc($err), lc($s)) >= 0; }
   return 1 unless $dbh;
   # consulta real: mas fiable que ping() sobre una conexion rota
   my $ok = eval { my $s=$dbh->prepare('SELECT 1'); $s->execute; $s->finish; 1 };
   return $ok ? 0 : 1;
}

# --- watchdog de disco: solo AVISA (drenar es lo que libera). Es el disco de CNM. ---
sub free_mb {
   my ($path)=@_;
   my $out = `df -Pk $path 2>/dev/null | tail -1`;
   my @c = split ' ', ($out//'');
   return (defined $c[3] && $c[3]=~/^\d+$/) ? int($c[3]/1024) : -1;
}
sub check_disk {
   my $free=free_mb($o{spool});
   if ($free>=0 && $free < $o{'min-free-mb'}) {
      warn_throttled('disk',"DISCO BAJO en $o{spool}: ${free}MB libres (< $o{'min-free-mb'}MB). Disco de CNM en riesgo.");
   }
}

# --- acotar error/ (proteccion de disco): purga los mas viejos por encima del tope ---
sub cap_error_dir {
   my $max=$o{'max-error-files'};
   opendir(my $dh,$ERR) or return;
   my @files = map {"$ERR/$_"} grep {/\.csv$/} readdir($dh);
   closedir($dh);
   return if scalar(@files) < $max;
   @files = sort { (stat($a))[9] <=> (stat($b))[9] } @files;
   my $to_del = scalar(@files) - $max + 1;
   for my $i (0..$to_del-1) { unlink $files[$i]; }
   warn_throttled('errcap',"error/ excede $max ficheros: purgados $to_del mas antiguos (proteccion de disco de CNM)");
}
sub to_error { my ($f)=@_; cap_error_dir(); rename($f,"$ERR/".basename($f)); }
sub to_ready { my ($f)=@_; rename($f,"$READY/".basename($f)); }   # devolver para reintento

# --- al arrancar: rescatar ficheros de TODOS los processing/<pid> de loaders
#     muertos y borrar sus directorios vacios. No toca el de un loader vivo
#     (permite varios loaders en paralelo). Los crawlers no se ven afectados:
#     usan crawler_id=range (estable), no el PID.
my $PROC_ROOT=$o{spool}.'/processing';
sub pid_alive { my ($pid)=@_; return ($pid=~/^\d+$/ && -d "/proc/$pid") ? 1 : 0; }
sub reclaim_stale {
   opendir(my $rh,$PROC_ROOT) or return;
   my @pdirs = grep { $_ ne '.' && $_ ne '..' } readdir($rh);
   closedir($rh);
   for my $pd (@pdirs) {
      my $dir="$PROC_ROOT/$pd";
      next unless -d $dir;
      next if ($pd ne $$ && pid_alive($pd));   # loader vivo: no tocar
      # rescatar sus ficheros a ready/ (carga idempotente) ...
      if (opendir(my $dh,$dir)) {
         while (defined(my $f=readdir($dh))) { next unless $f=~/\.csv$/; rename("$dir/$f","$READY/$f"); }
         closedir($dh);
      }
      # ... y borrar el directorio si es de un PID muerto (no el propio, que sigue vivo)
      if ($pd ne $$) { rmdir $dir; }   # rmdir solo borra si quedo vacio
   }
}

# --- reclama hasta $n ficheros de ready/ (recorre ready/ y subdirs por fecha) ---
sub claim_batch {
   my ($n)=@_;
   my @claimed; my @dirs=($READY);
   while (@dirs && @claimed<$n) {
      my $d=shift @dirs;
      opendir(my $dh,$d) or next;
      my @ent=sort grep { $_ ne '.' && $_ ne '..' } readdir($dh);
      closedir($dh);
      for my $e (@ent) {
         my $p="$d/$e";
         if (-d $p) { push @dirs,$p; next; }
         next unless $e=~/\.csv$/;
         if (rename($p,"$PROC/$e")) { push @claimed,"$PROC/$e"; last if @claimed>=$n; }
      }
   }
   return @claimed;
}

# elimina directorios de fecha vacios en ready/ (housekeeping)
sub cleanup_empty_dirs {
   my @dirs; my @stack=($READY);
   while (@stack) {
      my $d=shift @stack;
      opendir(my $dh,$d) or next;
      my @e=grep { $_ ne '.' && $_ ne '..' } readdir($dh);
      closedir($dh);
      for my $x (@e) { push @stack,"$d/$x" if -d "$d/$x"; }
      push @dirs,$d unless $d eq $READY;
   }
   for my $d (sort { length($b) <=> length($a) } @dirs) { rmdir $d; }
}

# --- carga un conjunto de ficheros en UNA transaccion ---
#   return: nº muestras (>=0) OK | -1 error de datos | -2 conexion caida
#   NO mueve ficheros: de eso se encarga load_batch (que aisla el culpable).
sub load_files {
   my ($dbh,@files)=@_;
   return 0 unless @files;
   my $rows=0; my $bad=0; my $nonum=0; my @nonum_ej;
   my $nmap=0; my $nunmap=0;      # cobertura del mapa id_metric->sem_instance_id
   my $ok=eval {
      # defensivo: si una transaccion anterior dejo restos, no arrastrar el fallo
      $dbh->do("DROP TABLE IF EXISTS stg");
      $dbh->do("CREATE TEMP TABLE stg (time timestamptz, id_metric int, ds smallint, value double precision, subtype text, sem_instance_id int) ON COMMIT DROP");
      $dbh->do("COPY stg (time,id_metric,ds,value,subtype,sem_instance_id) FROM STDIN WITH (FORMAT csv, NULL '')");
      for my $f (@files) {
         open(my $fh,'<',$f) or die "no abro $f: $!";
         while (my $ln=<$fh>) {
            chomp $ln; next if $ln eq '';
            # epoch,id_metric,ds,value,crawler_id,iid,subtype  (crawler_id/iid se ignoran)
            my @c=split(/,/,$ln,7);
            my ($t,$id,$ds,$v)=@c[0..3];
            my $subtype = defined $c[6] ? $c[6] : '';       # tolera lineas de 6 campos (formato viejo)
            unless (defined $t && $t=~/^\d+$/ && defined $id && $id=~/^\d+$/
                    && defined $ds && $ds=~/^\d+$/) { $bad++; next; }
            # VALOR: tiene que ser numerico. Un texto (p.ej. "Sqlcmd" emitido por
            # un script-metrica roto) rompia el COPY entero y tumbaba la
            # transaccion, arrastrando a todos los ficheros del lote. Se degrada
            # a NULL ("medido sin dato") y se registra para poder localizar la
            # metrica de origen.
            if (!defined $v || $v eq '' || $v eq 'U' || uc($v) eq 'NAN') {
               $v = '';                                     # -> NULL
            }
            elsif ($v !~ /^[+-]?(?:\d+\.?\d*|\.\d+)(?:[eE][+-]?\d+)?$/) {
               $nonum++;
               push @nonum_ej, "id_metric=$id ds=$ds valor='".substr($v,0,20)."'" if @nonum_ej < 3;
               $v = '';                                     # -> NULL, no rompe el COPY
            }
            # ENRIQUECIMIENTO: identidad estable. Ausente -> NULL (nunca se inventa
            # ni se bloquea la carga); se cuenta para poder vigilar la cobertura.
            my $inst = $IMAP{$id+0};
            if (defined $inst) { $nmap++; } else { $nunmap++; }
            $dbh->pg_putcopydata(join(',', iso($t), $id, $ds, $v, csv_field($subtype),
                                       (defined $inst ? $inst : ''))."\n");
            $rows++;
         }
         close($fh);
      }
      $dbh->pg_putcopyend();

      # --- COLAPSO one-hot (§4.9) ---
      # Las metricas cuyo subtype esta en sem_state_dict son estados one-hot:
      # se colapsan a UNA fila por (time,id_metric) con value = codigo del estado
      # activo (el ds cuyo value=1). Casos borde:
      #   exactamente un ds=1        -> value = ese ds (state_code)
      #   cero ds=1 o todo NULL      -> value = 0   (desconocido)
      #   mas de un ds=1             -> value = -1  (anomalia/transicion, no se esconde)
      # El resto de metricas (numericas) pasan tal cual. subtype NO se guarda en series.
      # NOTA sobre sem_instance_id en la rama one-hot: se incluye en el GROUP BY.
      # Es seguro porque el valor depende FUNCIONALMENTE de id_metric (sale del
      # hash %IMAP, constante dentro del lote para una misma metrica), asi que no
      # multiplica filas. No se usa max() para no enmascarar una hipotetica
      # inconsistencia: si algun dia partiera un grupo, se veria.
      $dbh->do(q{
         INSERT INTO series (time,id_metric,ds,value,sem_instance_id)
         -- numericas: subtype no esta en el diccionario -> passthrough
         SELECT s.time, s.id_metric, s.ds, s.value, s.sem_instance_id
         FROM stg s
         WHERE NOT EXISTS (SELECT 1 FROM sem_state_dict d WHERE d.subtype = s.subtype)
         UNION ALL
         -- one-hot: una fila por (time,id_metric) con el codigo de estado activo
         SELECT g.time, g.id_metric, 1::smallint AS ds,
                CASE WHEN g.n_hot = 1 THEN g.hot_ds
                     WHEN g.n_hot = 0 THEN 0
                     ELSE -1 END AS value,
                g.sem_instance_id
         FROM (
            SELECT s.time, s.id_metric, s.sem_instance_id,
                   count(*) FILTER (WHERE s.value = 1)              AS n_hot,
                   max(s.ds) FILTER (WHERE s.value = 1)             AS hot_ds
            FROM stg s
            WHERE EXISTS (SELECT 1 FROM sem_state_dict d WHERE d.subtype = s.subtype)
            GROUP BY s.time, s.id_metric, s.sem_instance_id
         ) g
         ON CONFLICT (time,id_metric,ds) DO NOTHING
      });
      $dbh->commit;
      1;
   };
   if (!$ok) {
      my $e=$@||'error';
      $e =~ s/\s+/ /g; $e = substr($e,0,300);
      eval { $dbh->rollback };
      $LAST_ERR = $e;
      return is_conn_error($dbh,$e) ? -2 : -1;
   }
   $LAST_ERR = '';
   if ($nonum) {
      log_err("$nonum valores NO NUMERICOS degradados a NULL (script-metrica de origen a revisar): "
             .join('; ',@nonum_ej));
   }
   # cobertura del enriquecimiento: si una parte grande del lote se queda sin
   # identidad estable, hay deriva (metrica nueva aun no espejada por el mirror,
   # o mirror parado). Se avisa de forma throttled; no es motivo de rechazo.
   if ($rows && $nunmap) {
      my $pct = int(100*$nunmap/$rows);
      warn_throttled('imapcov',"$nunmap de $rows muestras ($pct%) sin sem_instance_id "
         ."(metricas no presentes en sem_metric_binding; revisar si el mirror va al dia)")
         if $pct >= 10;
   }
   vlog("transaccion OK: ".scalar(@files)." ficheros, $rows muestras"
        .($bad?" ($bad lineas corruptas saltadas)":"").($nonum?" ($nonum valores no numericos->NULL)":"")
        ." [instancia: $nmap ok / $nunmap sin mapa]");
   return $rows;
}

# --- procesa un lote AISLANDO el fichero culpable ---
#   Si el lote falla por datos, NO se manda todo a cuarentena: se reintenta
#   fichero a fichero, de modo que solo el fichero realmente malo acaba en error/
#   y el resto se carga con normalidad. Sin esto, un unico fichero corrupto
#   arrastraba a los hasta --batch ficheros del lote (incidencia observada).
sub load_batch {
   my ($dbh,@files)=@_;
   return 0 unless @files;

   my $rc = load_files($dbh,@files);

   if ($rc >= 0) {                       # lote OK
      finish_ok(@files);
      vlog("lote OK: ".scalar(@files)." ficheros, $rc muestras");
      return $rc;
   }
   if ($rc == -2) {                      # conexion caida: devolver TODO a ready/
      to_ready($_) for @files;
      warn_throttled('dbdown',"Timescale inaccesible durante la carga: lote devuelto a ready/ ($LAST_ERR)");
      return -2;
   }

   # Un fallo puede dejar la sesion en estado sucio (temporales, transaccion
   # abortada) y hacer que TODOS los lotes siguientes fallen en cascada: asi un
   # fallo puntual acaba mandando a cuarentena decenas de ficheros sanos.
   # Se limpia la sesion antes de reintentar.
   reset_session($dbh);

   # rc == -1: error de datos. Si el lote era de 1 fichero, ese es el culpable.
   if (@files == 1) {
      log_err("FICHERO RECHAZADO ".basename($files[0]).": $LAST_ERR");
      to_error($files[0]);
      return -1;
   }

   # Lote de varios: reintentar uno a uno para no penalizar a los sanos.
   log_err("Error de datos en un lote de ".scalar(@files)." ficheros; se reintenta uno a uno para aislar el culpable ($LAST_ERR)");
   my ($ok_files,$bad_files,$total)=(0,0,0);
   for my $f (@files) {
      my $r = load_files($dbh,$f);
      if ($r >= 0)      { finish_ok($f); $ok_files++; $total+=$r; }
      elsif ($r == -2)  { to_ready($_) for ($f); $dbh=undef; last; }   # conexion caida a mitad
      else              { log_err("FICHERO RECHAZADO ".basename($f).": $LAST_ERR"); to_error($f); $bad_files++; }
   }
   log_err("Aislamiento completado: $ok_files ficheros cargados, $bad_files a cuarentena");
   return $total;
}

# reset_session: deja la sesion limpia tras un fallo (rollback + descarte de
#   temporales). Evita que un error puntual se propague al resto de lotes.
sub reset_session {
   my ($dbh)=@_;
   return unless $dbh;
   eval { $dbh->rollback };
   eval { $dbh->do("DISCARD TEMP") };
   1;
}

# marca un fichero como procesado con exito
sub finish_ok {
   for my $f (@_) {
      if ($o{archive}) { rename($f,"$DONE/".basename($f)); }
      else             { unlink $f; }
   }
}

# =================== bucle principal ===================
reclaim_stale();
refresh_instance_map(1);             # primera carga del mapa (no bloquea si falla)
my $dbh;
while (1) {
   check_disk();                     # avisa si el disco de CNM esta bajo
   cap_error_dir();                  # mantiene error/ acotado siempre
   refresh_instance_map();           # se auto-limita a 1 vez cada --map-refresh

   # asegurar conexion; si Timescale esta caido, el spool actua de buffer
   if (!alive($dbh)) {
      my $err;
      ($dbh,$err) = try_connect();
      if (!$dbh) {
         warn_throttled('nocon',"Timescale inaccesible ($err); el spool actua de buffer (hasta el techo del crawler)");
         last if $o{once};
         sleep $o{interval};
         next;
      }
      # comprobar dependencias del esquema ANTES de procesar: si falta
      # sem_state_dict, todas las cargas fallarian y mandarian a cuarentena
      # ficheros sanos. Mejor no tocar nada y avisar.
      unless (preflight($dbh)) {
         log_err("preflight fallido: no se procesa nada (los ficheros siguen en ready/)");
         $dbh = undef;
         last if $o{once};
         sleep $o{interval};
         next;
      }
   }

   my @f=claim_batch($o{batch});
   if (@f) {
      my $rc=load_batch($dbh,@f);
      $dbh=undef if $rc==-2;         # conexion caida -> reconectar en el proximo ciclo
   }
   else {
      cleanup_empty_dirs();
      last if $o{once};
      sleep $o{interval};
   }
}
rmdir $PROC if -d $PROC;   # limpiar el propio directorio al salir
exit 0;
