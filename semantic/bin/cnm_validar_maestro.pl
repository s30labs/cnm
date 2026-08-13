#!/usr/bin/perl
# =============================================================================
# cnm_validar_maestro.pl — validación PRE-VUELO del maestro de roles.
#
# Se ejecuta ANTES del generador, sobre el MISMO CSV que se va a cargar (así se
# valida exactamente el artefacto que entra, sin pasos de traducción de por medio).
#
# Es la primera de las dos puertas de calidad del ciclo de iteración:
#     [1] este validador  -> mira el fichero en si (lo que ha editado el cliente)
#     [2] cnm_generate_roles.pl (dry-run) -> lo contrasta contra la BD real
# Pasar la primera NO garantiza la segunda.
#
# Comprueba:
#   * ERRORES DUROS -> impiden cargar (el generador abortaria)
#   * AVISOS        -> cargaria, pero el dato seria inconsistente o inutil
#   * COBERTURA     -> % de relleno por campo, para seguir el avance entre iteraciones
#   * DIFF          -> que ha cambiado respecto de la version anterior (paso obligatorio)
#
# Dependencias: solo Text::CSV (la misma que ya usa el generador). Charset latin1.
#
# USO:
#   perl cnm_validar_maestro.pl --csv cnm_roles_maestro.csv
#   perl cnm_validar_maestro.pl --csv cnm_roles_maestro.csv \
#        --diff historico/cnm_roles_maestro_20260720.csv
#
# Codigo de salida: 0 si no hay errores duros, 1 si los hay (encadenable en scripts).
# =============================================================================
use strict;
use warnings;
use Text::CSV;
use Getopt::Long;
use FindBin;
use lib $FindBin::Bin;
use CNMSemanticConf;

my %o = ( csv=>undef, diff=>undef, 'max-list'=>25, conf=>undef );
GetOptions(\%o,'csv=s','diff=s','max-list=i','conf=s') or die "Argumentos invalidos\n";
die "Falta --csv <fichero>\n" unless $o{csv};

# --- vocabularios (deben coincidir con el esquema y la guia de roles) ---
my %TIPOS  = map {$_=>1} qw(business_process business_subprocess application technical_service site);
my %STATUS = map {$_=>1} qw(draft active deprecated archived);
# El vocabulario geografico es ESPECIFICO DEL CLIENTE -> viene de semantic.conf.
# Los de arriba (TIPOS, STATUS) son de PRODUCTO: salen del ENUM del esquema.
my $CFG    = CNMSemanticConf->load($o{conf});
my %GEO    = map {$_=>1} $CFG->list('geography_vocab');
my @CLAVE  = qw(role_id role_type display_name domain environment status);

# ---------------------------------------------------------------------------
# Detecta el separador de la cabecera: Excel en español exporta con ';', en
# ingles con ','. Sin esto, el fichero se lee como UNA sola columna.
sub detectar_sep {
   my ($path)=@_;
   open(my $fh,'<',$path) or die "No puedo abrir $path: $!\n";
   my $l = <$fh>; close($fh);
   return ',' unless defined $l;
   my $nc = ($l =~ tr/,//); my $ns = ($l =~ tr/;//);
   return $ns > $nc ? ';' : ',';
}

sub cargar {
   my ($path)=@_;
   my $sep = detectar_sep($path);
   open(my $fh,'<',$path) or die "No puedo abrir $path: $!\n";
   my $csv = Text::CSV->new({ binary=>1, sep_char=>$sep, auto_diag=>1 });
   my $hdr = $csv->getline($fh) or die "CSV vacio o ilegible: $path\n";
   my @H = map { my $x=$_; $x='' unless defined $x; $x=~s/^\x{feff}//; trim($x) } @$hdr;
   my @filas;
   while (my $row = $csv->getline($fh)) {
      next unless grep { defined $_ && $_ ne '' } @$row;
      my %h;
      for my $i (0..$#H) { $h{$H[$i]} = defined $row->[$i] ? trim($row->[$i]) : ''; }
      push @filas, \%h;
   }
   close($fh);
   return (\@H,\@filas,$sep);
}
sub trim { my $s=shift; return '' unless defined $s; $s=~s/^\s+|\s+$//g; return $s; }
sub val  { my ($h,$c)=@_; return defined $h->{$c} ? $h->{$c} : ''; }

# ---------------------------------------------------------------------------
my ($H,$F,$SEP) = cargar($o{csv});
my $n = scalar @$F;
my (@err,@warn);

print "=== VALIDACION DEL MAESTRO: $o{csv} ===\n";
print "Config: ".$CFG->source."   (geografia admitida: ".join(',', sort keys %GEO).")\n";
print "Roles: $n   (separador detectado: '$SEP')\n\n";
die "El CSV no tiene filas de datos.\n" unless $n;

# ---------- ERRORES DUROS ----------
my (%vistos,%esid);
my $ln=1;
for my $h (@$F) {
   $ln++;
   my $rid = val($h,'role_id');
   if ($rid eq '') { push @err,"fila $ln: sin role_id"; next; }
   if ($vistos{$rid}++) { push @err,"role_id duplicado: '$rid'"; }
   $esid{$rid}=1;

   my $rt = val($h,'role_type');
   push @err,"$rid: role_type invalido '$rt'" unless $TIPOS{$rt};

   my $st = val($h,'status');
   push @err,"$rid: status invalido '$st'" if $st ne '' && !$STATUS{$st};

   my $cr = val($h,'criticality');
   push @err,"$rid: criticality fuera de 1-5 ('$cr')" if $cr ne '' && $cr !~ /^[1-5]$/;

   for my $c (@CLAVE) {
      push @err,"$rid: campo obligatorio vacio '$c'" if val($h,$c) eq '';
   }
}
# parents: existencia, auto-referencia
my %padre;
for my $h (@$F) {
   my $rid=val($h,'role_id'); next if $rid eq '';
   my $p=val($h,'parent_role_id');
   $padre{$rid}=$p;
   next if $p eq '';
   push @err,"$rid: parent_role_id inexistente '$p'" unless $esid{$p};
   push @err,"$rid: es su propio parent"             if $p eq $rid;
}
# ciclos de composicion
for my $rid (keys %padre) {
   my %visto; my $cur=$rid; my $pasos=0;
   while (defined $cur && $cur ne '' && exists $padre{$cur}) {
      if ($visto{$cur}++) { push @err,"ciclo de composicion en '$rid'"; last; }
      $cur = $padre{$cur};
      last if ++$pasos > 100;
   }
}

# ---------- AVISOS ----------
my @singeo = grep { val($_,'geography') eq '' } @$F;
push @warn, sprintf("%d roles sin geography (regla: nunca vacio; ISO-2 o WW)", scalar @singeo) if @singeo;

my @malgeo = grep { val($_,'geography') ne '' && !$GEO{val($_,'geography')} } @$F;
if (@malgeo) {
   my $ej = join(', ', map { val($_,'role_id')."='".val($_,'geography')."'" } @malgeo[0..($#malgeo>2?2:$#malgeo)]);
   push @warn, sprintf("%d con geography fuera del vocabulario (%s): %s",
      scalar @malgeo, join('/',sort keys %GEO), $ej);
}

my %crit; $crit{val($_,'criticality')}++ for grep { val($_,'criticality') ne '' } @$F;
if (scalar(keys %crit)==1) {
   my ($k)=keys %crit;
   push @warn, "criticality es CONSTANTE ('$k' en $crit{$k} roles): no aporta informacion "
             . "y anula la ponderacion de severidad de las senales";
}

my @dups = grep { val($_,'role_id') =~ /__dup/ } @$F;
push @warn, sprintf("%d filas __dup: el generador las EXCLUYE en silencio -> %s",
   scalar @dups, join(', ', map { val($_,'role_id') } @dups)) if @dups;

my $sin_owner = grep { val($_,'owner') eq '' } @$F;
push @warn, "owner vacio en los $n roles (bloqueado por el catalogo sem_org_unit)" if $sin_owner==$n;

my @huerf = grep { val($_,'role_type') eq 'site' && val($_,'parent_role_id') eq '' } @$F;
push @warn, sprintf("%d sites sin parent (fuera de la jerarquia de composicion)", scalar @huerf) if @huerf;

my $draft = grep { val($_,'status') eq 'draft' } @$F;
push @warn, "$draft roles en status=draft: decidir si v1 los consume o se promueven a active" if $draft;

# ---------- SALIDA ----------
printf "--- ERRORES DUROS: %d ---\n", scalar @err;
if (@err) {
   my $lim = $o{'max-list'};
   for my $i (0..($#err < $lim-1 ? $#err : $lim-1)) { print "  x $err[$i]\n"; }
   printf "  ... y %d mas\n", scalar(@err)-$lim if @err > $lim;
} else { print "  (ninguno: el fichero es cargable)\n"; }

printf "\n--- AVISOS: %d ---\n", scalar @warn;
if (@warn) { print "  ! $_\n" for @warn; } else { print "  (ninguno)\n"; }

print "\n--- COBERTURA POR CAMPO ---\n";
for my $c (@$H) {
   next if $c eq '';
   my $f = grep { val($_,$c) ne '' } @$F;
   my $pct = int(100*$f/$n);
   printf "  %-18s %4d/%d %3d%%  %s\n", $c, $f, $n, $pct, '#' x int($f*20/$n);
}

print "\n--- REPARTO ---\n";
for my $campo (qw(role_type status geography criticality)) {
   next unless grep { $_ eq $campo } @$H;
   my %c; $c{ val($_,$campo) ne '' ? val($_,$campo) : '(vacio)' }++ for @$F;
   print "  $campo: ".join(', ', map {"$_=$c{$_}"} sort { $c{$b} <=> $c{$a} || $a cmp $b } keys %c)."\n";
}

# ---------- DIFF ----------
if ($o{diff}) {
   print "\n--- DIFF contra $o{diff} ---\n";
   my ($H0,$F0) = cargar($o{diff});
   my (%A,%B);
   for my $h (@$F0) { my $r=val($h,'role_id'); $A{$r}=$h if $r ne ''; }
   for my $h (@$F)  { my $r=val($h,'role_id'); $B{$r}=$h if $r ne ''; }

   my @nuevos   = sort grep { !exists $A{$_} } keys %B;
   my @quitados = sort grep { !exists $B{$_} } keys %A;
   printf "  roles nuevos:    %d%s\n", scalar @nuevos,
      (@nuevos ? '  '.join(', ', @nuevos[0..($#nuevos>4?4:$#nuevos)]) : '');
   printf "  roles quitados:  %d%s\n", scalar @quitados,
      (@quitados ? '  '.join(', ', @quitados[0..($#quitados>4?4:$#quitados)]) : '');
   print "    ATENCION: quitar filas NO borra el rol en BD. Para retirar un rol -> status=deprecated.\n"
      if @quitados;

   my (%cambios,%ejemplo); my $n_mod=0;
   for my $rid (sort keys %B) {
      next unless exists $A{$rid};
      my $mod=0;
      for my $c (@$H) {
         next if $c eq '';
         next unless exists $A{$rid}{$c};
         my ($x,$y)=(val($A{$rid},$c), val($B{$rid},$c));
         next if $x eq $y;
         $mod=1; $cambios{$c}++;
         $ejemplo{$c} = "$rid: '$x' -> '$y'" unless exists $ejemplo{$c};
      }
      $n_mod++ if $mod;
   }
   print "  roles modificados: $n_mod\n";
   for my $c (sort { $cambios{$b} <=> $cambios{$a} } keys %cambios) {
      printf "    %-18s %d cambios   p.ej. %s\n", $c, $cambios{$c}, $ejemplo{$c};
   }
   print "\n  >> Si estos numeros NO cuadran con lo que has editado, PARA y revisa\n";
   print "     (un filtro mal aplicado o un arrastre en Excel cambia cientos de filas).\n";
}

print "\n".(@err ? "RESULTADO: NO CARGABLE (corregir errores duros)" : "RESULTADO: CARGABLE")."\n";
exit(@err ? 1 : 0);
