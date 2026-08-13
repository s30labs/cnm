package Crawler::Spool;
# =============================================================================
# Crawler::Spool — escritura dual al *spool* de TimescaleDB desde los crawlers.
#
# Sigue el convenio OO de Crawler::Store (objeto $self, método ->log, accesores
# de configuración) y se encarga de TODA la gestión de directorios del spool.
#
# MODELO (ver documento de arquitectura §3):
#   Un fichero por CRAWLER y CICLO. Se abre un temporal en tmp/ al empezar el
#   ciclo (begin), se hace append por métrica (write) —baratísimo, es print a
#   un descriptor abierto—, y al terminar (commit) se cierra y se hace un ÚNICO
#   rename() atómico a ready/YYYY/MM/DD/HH/. El loader solo ve ficheros ya
#   completos (garantía = atomicidad del rename, no el nombre).
#
#   tmp/  --(commit: rename)-->  ready/  --(lo reclama el loader)-->  processing/
#   Un crawler caído deja el temporal en tmp/; recover() lo rescata a ready/
#   (cada línea es una muestra independiente, así que un parcial es cargable).
#
# FORMATO de línea (CSV, una por DS): epoch,id_metric,ds,value,crawler_id,iid,subtype
#   - value 'U' = medido sin dato (el loader lo convierte a NULL).
#   - subtype viaja SOLO para decidir el colapso one-hot (§4.9) en el loader;
#     NO se almacena en 'series'.
#   - se emiten TODAS las DS crudas; el colapso de estados one-hot (§4.9) y la
#     resolución semántica se hacen aguas abajo (loader), no aquí.
#
# REQUISITO: tmp/ y ready/ bajo el MISMO filesystem (rename atómico).
#
# VALIDACIÓN: probar en un crawler de test contra un spool de prueba; verificar
#   que (a) un ciclo normal produce 1 fichero en ready/ con N líneas, (b) matar
#   el crawler a media deja el parcial en tmp/ y recover() lo rescata, (c) el
#   loader ingiere ambos sin duplicar (idempotencia por (time,id_metric,ds)).
# =============================================================================
use strict;
use warnings;
use POSIX qw(strftime);
use File::Path qw(make_path);
use IO::Handle;

# new(%opts): path (raíz del spool), crawler_id, logger (coderef opcional),
#             fsync (0/1, best-effort durabilidad ante corte eléctrico)
sub new {
   my ($class,%o)=@_;
   my $self={
      path       => $o{path}       // '/opt/data/spool/ts',
      crawler_id => $o{crawler_id} // $$,
      logger     => $o{logger},
      fsync      => $o{fsync}      // 0,
      seq        => 0,
      _fh    => undef, _tmp => undef, _final => undef, _lines => 0, _t => undef,
   };
   bless $self,$class;
   $self->_ensure($self->_tmp_dir);   # garantizar tmp/
   return $self;
}

sub log {
   my ($self,$lvl,$msg)=@_;
   $self->{logger}->($lvl,$msg) if ref $self->{logger} eq 'CODE';
   return;
}

sub _tmp_dir { my $s=shift; return $s->{path}.'/tmp'; }

sub _ready_dir {
   my ($s,$t)=@_;
   return $s->{path}.'/ready/'.strftime('%Y/%m/%d/%H', localtime($t // time));
}

sub _ensure {
   my ($s,$dir)=@_;
   unless (-d $dir) { make_path($dir,{mode=>0775}); }
   return -d $dir;
}

# begin($t): abre el temporal del ciclo. Devuelve 1/0.
sub begin {
   my ($s,$t)=@_;
   $t //= time;
   # BACKPRESSURE (protege el disco de CNM): si ready/ no se drena —loader o
   # Timescale caidos—, NO se escribe mas al spool. El RRD/consola siguen intactos.
   my ($why,$val)=$s->_ready_over_limit();
   if ($why) {
      $s->_warn_throttled("Spool::begin BACKPRESSURE ($why=$val): se omite el volcado analitico de este ciclo (RRD intacto)");
      $s->{_fh}=undef;
      return 0;
   }
   $s->{seq}++;
   my $name  = sprintf('%s_%d_%d.csv', $s->{crawler_id}, $t, $s->{seq});
   my $tmp   = $s->_tmp_dir.'/'.$name;
   my $final = $s->_ready_dir($t).'/'.$name;
   my $fh;
   unless (open($fh,'>',$tmp)) {
      $s->log('warning',"Spool::begin no puedo abrir $tmp: $!");
      return 0;
   }
   $fh->autoflush(0);          # buffer en Perl; se vuelca en bloques (barato)
   $s->{_fh}=$fh; $s->{_tmp}=$tmp; $s->{_final}=$final; $s->{_lines}=0; $s->{_t}=$t;
   return 1;
}

# write($t,$id_metric,$values_ref,$iid,$subtype): una línea por DS. Devuelve 1/0.
#   Llamar dentro del bucle de métricas, junto a la escritura RRD.
#   subtype viaja en la linea SOLO para decidir el colapso one-hot (§4.9) en el
#   loader; NO se almacena en 'series'.
sub write {
   my ($s,$t,$id_metric,$values,$iid,$subtype)=@_;
   return 0 unless $s->{_fh};
   my $fh=$s->{_fh};
   my $cid=$s->{crawler_id};
   $iid = defined $iid ? $iid : '';
   $subtype = defined $subtype ? $subtype : '';
   my $ds=0;
   for my $v (@$values) {
      $ds++;
      my $val = defined $v ? $v : 'U';
      unless (print $fh join(',', $t, $id_metric, $ds, $val, $cid, $iid, $subtype),"\n") {
         $s->log('warning',"Spool::write fallo en $s->{_tmp}: $!");
         return 0;
      }
      $s->{_lines}++;
   }
   return 1;
}

# commit(): flush + (fsync opcional) + rename atómico tmp->ready. Devuelve 1/0.
sub commit {
   my ($s)=@_;
   return 0 unless $s->{_fh};
   my $fh=$s->{_fh};
   $fh->flush;
   if ($s->{fsync}) { eval { $fh->sync }; }     # best-effort (no en todos los FH)
   close($fh);
   $s->{_fh}=undef;
   if ($s->{_lines}==0) {                         # ciclo sin datos: no dejar vacío
      unlink $s->{_tmp};
      return 1;
   }
   my ($dir)= $s->{_final}=~ m{^(.*)/[^/]+$};
   $s->_ensure($dir);
   unless (rename($s->{_tmp}, $s->{_final})) {
      $s->log('warning',"Spool::commit rename $s->{_tmp} -> $s->{_final}: $!");
      return 0;
   }
   $s->log('debug',"Spool::commit $s->{_final} ($s->{_lines} lineas)");
   return 1;
}

# abort($discard): cierra el temporal. Por defecto lo DEJA para recover();
#   con $discard true lo borra.
sub abort {
   my ($s,$discard)=@_;
   if ($s->{_fh}) { close($s->{_fh}); $s->{_fh}=undef; }
   if ($discard && $s->{_tmp} && -e $s->{_tmp}) { unlink $s->{_tmp}; }
   return 1;
}

# recover($max_age): rescata temporales huérfanos (crawler caído) a ready/.
#   Solo toca los más viejos que $max_age (por defecto 900s, muy por encima de
#   un ciclo) para no pisar un fichero que aún se esté escribiendo.
sub recover {
   my ($s,$max_age)=@_;
   $max_age //= 900;
   my $tmpd=$s->_tmp_dir;
   opendir(my $dh,$tmpd) or return 0;
   my $n=0;
   while (defined(my $f=readdir($dh))) {
      next unless $f=~/\.csv$/;
      my $p="$tmpd/$f";
      my @st=stat($p); next unless @st;
      next if (time - $st[9]) < $max_age;         # aún podría estar en uso
      if ($st[7]==0) { unlink $p; next; }          # vacío
      my ($epoch)= $f=~/^[^_]+_(\d+)_\d+\.csv$/;
      $epoch //= time;
      my $rdir=$s->_ready_dir($epoch); $s->_ensure($rdir);
      if (rename($p,"$rdir/$f")) { $n++; $s->log('info',"Spool::recover rescatado $f"); }
   }
   closedir($dh);
   return $n;
}

# _ready_over_limit: ¿el spool acumula demasiado? (loader/Timescale caidos)
#   Señal PRINCIPAL: antiguedad del fichero mas viejo en ready/ (CNM_TS_SPOOL_MAX_AGE,
#   por defecto 3h). Señal secundaria: nº de ficheros (CNM_TS_SPOOL_MAX_FILES).
#   Sale en cuanto detecta la primera transgresion (coste acotado incluso con backlog).
sub _ready_over_limit {
   my ($s)=@_;
   my $max_files = $ENV{CNM_TS_SPOOL_MAX_FILES} || 4000;
   my $max_age   = $ENV{CNM_TS_SPOOL_MAX_AGE}   || 10800;   # 3h
   my $now = time;
   my $count = 0;
   my @stack = ($s->{path}.'/ready');
   while (@stack) {
      my $d = pop @stack;
      opendir(my $dh,$d) or next;
      while (defined(my $e=readdir($dh))) {
         next if $e eq '.' || $e eq '..';
         my $p = "$d/$e";
         if (-d $p) { push @stack,$p; next; }
         next unless $e =~ /\.csv$/;
         $count++;
         if ($count > $max_files) { closedir($dh); return ('files',$count); }
         my @st = stat($p);
         if (@st && ($now - $st[9]) > $max_age) { closedir($dh); return ('age',$now-$st[9]); }
      }
      closedir($dh);
   }
   return (undef,$count);
}

# _warn_throttled: 1 aviso como maximo cada 5 min (evita spam cuando el
#   backpressure se mantiene ciclo tras ciclo).
sub _warn_throttled {
   my ($s,$msg)=@_;
   my $now=time;
   if (!$s->{_last_warn} || ($now - $s->{_last_warn}) > 300) {
      $s->log('warning',$msg);
      $s->{_last_warn}=$now;
   }
}

1;
