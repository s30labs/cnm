#!/usr/bin/perl
# =============================================================================
# cnm_binding.pl — Trabajo B: asigna instancia -> rol en sem_binding_role.
#
# JUICIO semántico (distinto del espejo factual). Para cada instancia viva:
#   1. importancia: watch<>0 OR subtype disp/latency (disp_icmp, mon_*, w_mon_*).
#   2. resolver ROL por físico/paraguas:
#        físico   -> código > col7 > (type: NO en v1)
#        paraguas -> col7 > código > (type: NO en v1)   (paraguas = IP 1.1.0.0/16)
#      código -> rol vía mapa jerárquico de dos pasadas (cnm_derive_code_map.pl):
#        X##-SP## (subprocess) ; si no, X## (process) ; si no, sin rol.
#      código se lee de c_label (prioridad) o label de las métricas de la instancia.
#   3. signal_class SIEMPRE del concepto (subtype/canonical_override); no del código.
#   4. is_primary/weight por canal (salud/riesgo).
#
# Propiedades: DRY-RUN por defecto (--commit escribe). ADITIVO / NO DESTRUCTIVO
# (upsert; nunca borra: eso es reconcile). PRESERVA bindings human_confirmed.
# IDEMPOTENTE. Valida FK (role_id activo). Rollback ante error.
#
# NO ejecutar --commit en producción hasta que col7 esté estable (ver design/binding.md).
#
#   perl cnm_binding.pl --user U --pass P --db onm [--host H]
#        --map cnm_code_role_map.csv [--field-id 7] [--commit] [-v]
# =============================================================================
use strict; use warnings;
use FindBin; use lib $FindBin::Bin;
use DBI; use Getopt::Long;

my %o=(host=>'127.0.0.1', db=>'onm', 'field-id'=>7, commit=>0, v=>0, map=>'');
GetOptions(\%o,'user=s','pass=s','db=s','host=s','map=s','field-id=i','commit','v') or die;
defined $o{user} && defined $o{pass} or die "Faltan --user/--pass\n";
$o{map} or die "Falta --map <cnm_code_role_map.csv> (salida de cnm_derive_code_map.pl)\n";
my $DRY=!$o{commit};
my $COL='columna'.$o{'field-id'};

# ---------------------------------------------------------------------------
# 1. cargar el mapa código->rol (dos niveles: subprocess / process)
# ---------------------------------------------------------------------------
my %map_sp; my %map_proc;      # prefijo -> role_id
open(my $mf,'<:encoding(latin1)',$o{map}) or die "No puedo abrir mapa $o{map}: $!\n";
my $mh=<$mf>;                  # cabecera
while (my $l=<$mf>) {
  $l=~s/\r?\n//; next unless length $l;
  my ($prefix,$level,$rid)=split /;/,$l;
  next unless $prefix && $rid;
  if    ($level eq 'subprocess') { $map_sp{$prefix}=$rid; }
  elsif ($level eq 'process')    { $map_proc{$prefix}=$rid; }
}
close($mf);
printf "Mapa código->rol: %d subprocesos + %d procesos (fallback)\n",
       scalar keys %map_sp, scalar keys %map_proc;
print  "MODO: ",($DRY?"DRY-RUN (no escribe; usa --commit)":"COMMIT"),"\n";

# resolver un código completo a rol (dos pasadas)
sub codigo_a_rol {
  my ($codigo)=@_;   # X##-SP##-KPI#### (o similar)
  return undef unless defined $codigo;
  my ($proc_sp)= $codigo=~/^([PWTIBD]\d+-SP\d+)-KPI/;
  my ($proc)   = $codigo=~/^([PWTIBD]\d+)-SP/;
  return $map_sp{$proc_sp}   if $proc_sp && $map_sp{$proc_sp};      # 1) subproceso
  return $map_proc{$proc}    if $proc    && $map_proc{$proc};       # 2) proceso fallback
  return undef;                                                     # 3) sin rol
}
# extraer el código KPI de un texto (c_label o label)
sub extraer_codigo {
  my ($txt)=@_; return undef unless defined $txt && length $txt;
  return $1 if $txt=~/([PWTIBD]\d+-SP\d+-KPI\d+)/;
  return undef;
}

my $dbh=DBI->connect("DBI:mysql:database=$o{db};host=$o{host}",$o{user},$o{pass},
       {RaiseError=>1,AutoCommit=>0,mysql_enable_utf8=>0}) or die DBI->errstr;

# ---------------------------------------------------------------------------
# 2. cargas auxiliares en memoria (evita consultas por instancia)
# ---------------------------------------------------------------------------
# 2a. roles activos (validación FK del destino)
my %role_ok=map {$_->[0]=>1}
   @{$dbh->selectall_arrayref("SELECT role_id FROM sem_business_role WHERE status='active'")};
printf "Roles activos (destinos válidos): %d\n", scalar keys %role_ok;

# 2b. dispositivos: id_dev -> {ip,type,col7}
my %dev;
{
  my $q=$dbh->prepare(
    "SELECT d.id_dev, d.ip, d.type, c.$COL AS col7
       FROM devices d LEFT JOIN devices_custom_data c ON c.id_dev=d.id_dev");
  $q->execute;
  while (my ($id,$ip,$type,$col7)=$q->fetchrow_array){
    $col7='' if !defined $col7 || $col7 eq '-';
    $dev{$id}={ip=>($ip//''),type=>($type//''),col7=>($col7//'')};
  }
}

# 2c. signal_class efectiva por concepto: canonical_id -> signal_class
my %sig_of;
{
  my $q=$dbh->prepare("SELECT canonical_id, signal_class FROM sem_canonical_concept");
  $q->execute; while (my ($c,$s)=$q->fetchrow_array){ $sig_of{$c}=$s; }
}
# subtype -> canonical_id
my %concept_of;
{
  my $q=$dbh->prepare("SELECT subtype, canonical_id FROM sem_metric_concept");
  $q->execute; while (my ($st,$c)=$q->fetchrow_array){ $concept_of{$st}=$c; }
}

# 2d. bindings de rol ya existentes (para preservar human_confirmed e idempotencia)
my %existing;   # "instance_id|role_id" -> {confidence,is_primary,weight}
{
  my $q=$dbh->prepare("SELECT instance_id,role_id,confidence,is_primary,weight FROM sem_binding_role");
  $q->execute;
  while (my ($iid,$rid,$conf,$prim,$w)=$q->fetchrow_array){
    $existing{"$iid|$rid"}={confidence=>$conf,is_primary=>$prim,weight=>$w};
  }
}

# 2e. métricas activas por instancia: instance_id -> [{subtype,watch,c_label,label}]
#     (para importancia y extracción de código)
my %inst_metrics;
{
  my $q=$dbh->prepare(
    "SELECT b.instance_id, m.subtype, m.watch, m.c_label, m.label
       FROM sem_metric_binding b
       JOIN metrics m ON m.id_metric=b.idmetric
      WHERE b.status='active'");
  $q->execute;
  while (my ($iid,$st,$watch,$cl,$lb)=$q->fetchrow_array){
    push @{$inst_metrics{$iid}}, {subtype=>$st,watch=>($watch//'0'),c_label=>$cl,label=>$lb};
  }
}

# ---------------------------------------------------------------------------
# 3. resolver cada instancia viva -> rol + signal_class
# ---------------------------------------------------------------------------
sub es_importante {
  my ($mets)=@_;
  for my $m (@$mets){
    return 1 if defined $m->{watch} && $m->{watch} ne '0' && $m->{watch} ne '';
    return 1 if $m->{subtype}=~/^(disp_icmp|mon_|w_mon_)/;
    # código KPI = declaración humana explícita de relevancia de negocio
    return 1 if extraer_codigo($m->{c_label}) || extraer_codigo($m->{label});
  }
  return 0;
}
sub es_paraguas { my ($ip)=@_; return $ip=~/^1\.1\.\d{1,3}\.\d{1,3}$/ ? 1 : 0; }

my $iq=$dbh->prepare(
  "SELECT instance_id, iddev, subtype, canonical_override FROM sem_instance WHERE valid_to IS NULL");
$iq->execute;

my %stat; my @sin_rol; my @paraguas_sin_col7; my @rol_inexistente;
my @plan;   # {instance_id, role_id, signal_class}
while (my ($iid,$iddev,$subtype,$override)=$iq->fetchrow_array){
  $stat{instancias_vivas}++;
  my $mets=$inst_metrics{$iid}||[];
  # importancia
  my $imp = es_importante($mets);
  $stat{importantes}++ if $imp;
  next unless $imp;   # v1: solo importantes (política acordada)

  my $d=$dev{$iddev}||{ip=>'',type=>'',col7=>''};
  my $paraguas = es_paraguas($d->{ip});
  # código (c_label prioridad sobre label), de cualquier métrica de la instancia
  my $codigo;
  for my $m (@$mets){
    $codigo = extraer_codigo($m->{c_label}) // extraer_codigo($m->{label});
    last if $codigo;
  }
  my $rol_codigo = codigo_a_rol($codigo);
  my $rol_col7   = ($d->{col7} && $role_ok{$d->{col7}}) ? $d->{col7} : undef;

  # resolución por físico/paraguas (SIN fallback type en v1).
  # $via registra CÓMO se resolvió, para poder auditar la fiabilidad del binding:
  #   'direct'  = por código KPI propio de la métrica (atribución explícita, fiable)
  #   'derived' = heredado del col7 del dispositivo (atribución por defecto, más débil)
  my ($rol,$via);
  if ($paraguas){
    if    (defined $rol_col7)   { $rol=$rol_col7;   $via='derived'; }
    elsif (defined $rol_codigo) { $rol=$rol_codigo; $via='direct'; }
  } else {
    if    (defined $rol_codigo) { $rol=$rol_codigo; $via='direct'; }
    elsif (defined $rol_col7)   { $rol=$rol_col7;   $via='derived'; }
  }

  if (!$rol){
    $stat{sin_rol}++;
    push @sin_rol,[$iid,$subtype,$d->{type}] if @sin_rol<30;
    push @paraguas_sin_col7,[$iid,$d->{ip}] if $paraguas && !$d->{col7} && @paraguas_sin_col7<30;
    next;
  }
  # validar FK (el rol resuelto debe existir y estar activo)
  unless ($role_ok{$rol}){
    $stat{rol_inexistente}++;
    push @rol_inexistente,[$iid,$rol] if @rol_inexistente<30;
    next;
  }
  # signal_class efectiva: canonical_override si existe, si no el del subtype
  my $canon = ($override && $sig_of{$override}) ? $override : $concept_of{$subtype};
  my $sig = ($canon && $sig_of{$canon}) ? $sig_of{$canon} : 'diagnostic';
  push @plan,{instance_id=>$iid,role_id=>$rol,signal_class=>$sig,subtype=>$subtype,
              mets=>$mets,via=>$via,iddev=>$iddev};
  $stat{con_rol}++;
}

# ---------------------------------------------------------------------------
# 4. is_primary / weight por canal (salud/riesgo) — segunda pasada
#    POR ROL **Y POR DISPOSITIVO** (ver REV-SEM-03, accion 1)
#
# CAMBIO RESPECTO A v1: antes se agrupaba solo por rol, lo que daba UNA primaria
# por rol. Eso asume que el rol tiene un unico punto de entrada, y es falso para
# el 47,3% de los roles con senal de salud: un rol de tipo 'site' agrupa varios
# equipos y ninguno lo "representa".
#
# Efecto medido con la regla antigua: 1.046 dispositivos monitorizados NO podian
# reflejar una caida en la salud de su rol, porque ninguna de sus senales estaba
# marcada como primaria -- ni podia estarlo. Caso real (site.es_ai_bcn): la
# primaria registro 61 segundos de unos 40 dias de caidas entre dos equipos.
#
# AHORA: una primaria por (rol, dispositivo, canal). Asi is_primary recupera un
# significado no arbitrario: "la senal que define si ESTE equipo funciona".
# Como se combinan los dispositivos para dar la salud del ROL es una decision
# aparte (health_threshold en sem_business_role), no del binding.
#
# El esquema NO cambia: la PK es (instance_id, role_id) y is_primary es un
# booleano por binding, asi que varias primarias por rol ya eran representables.
# Solo lo prohibia esta regla.
# ---------------------------------------------------------------------------
# agrupar por rol Y dispositivo
my %by_role_dev;
push @{$by_role_dev{ $_->{role_id}.'|'.($_->{iddev}//0) }}, $_ for @plan;

sub es_disponibilidad {   # candidata a primaria de SALUD en app/servicio/site
  my ($p)=@_;
  for my $m (@{$p->{mets}}){ return 1 if $m->{subtype}=~/^(disp_icmp|mon_icmp|w_mon_|mon_)/; }
  return 0;
}
sub tiene_codigo {
  my ($p)=@_;
  for my $m (@{$p->{mets}}){ return 1 if extraer_codigo($m->{c_label})||extraer_codigo($m->{label}); }
  return 0;
}

my %attr;   # instance_id|role_id -> {is_primary,weight}
for my $k (keys %by_role_dev){
  my @items=@{$by_role_dev{$k}};
  my ($rid) = split /\|/, $k, 2;
  # candidatos de salud (health_sli) y de riesgo (saturation)
  my @health = grep { $_->{signal_class} eq 'health_sli' } @items;
  my @risk   = grep { $_->{signal_class} eq 'saturation' } @items;
  # primaria de salud: disponibilidad primero; si es proc/subproc, un KPI; si no, la 1ª
  my $health_primary;
  if (@health){
    my ($disp) = grep { es_disponibilidad($_) } @health;
    my ($kpi)  = grep { tiene_codigo($_) } @health;
    $health_primary = $disp // $kpi // (sort {$a->{instance_id}<=>$b->{instance_id}} @health)[0];
  }
  # primaria de riesgo: la 1ª saturation (determinista); peso uniforme 0.5
  my $risk_primary = (sort {$a->{instance_id}<=>$b->{instance_id}} @risk)[0];

  for my $p (@items){
    my ($prim,$w)=(0,0.0);
    if ($p->{signal_class} eq 'health_sli'){
      if (defined $health_primary && $p==$health_primary){ $prim=1; $w=1.00; }
      else { $prim=0; $w=0.50; }
    } elsif ($p->{signal_class} eq 'saturation'){
      $prim = (defined $risk_primary && $p==$risk_primary) ? 1 : 0;
      $w=0.50;
    } else { $prim=0; $w=0.00; }   # diagnostic/informative: no agregan
    $attr{"$p->{instance_id}|$rid"}={is_primary=>$prim,weight=>$w};
  }
}

# ---------------------------------------------------------------------------
# 5. informe
# ---------------------------------------------------------------------------
printf "\n=== RESUMEN ===\n";
printf "  instancias vivas              : %d\n",$stat{instancias_vivas}//0;
printf "  importantes (watch/disp/lat)  : %d\n",$stat{importantes}//0;
printf "  -> con rol resuelto           : %d\n",$stat{con_rol}//0;
printf "  -> SIN rol (ni código ni col7): %d\n",$stat{sin_rol}//0;
printf "  -> rol resuelto INEXISTENTE   : %d\n",$stat{rol_inexistente}//0;
if (@paraguas_sin_col7){
  printf "  ! paraguas SIN col7 (anomalía a corregir a mano): %d\n",scalar @paraguas_sin_col7;
}
# reparto por signal_class del plan
my %bs; $bs{$_->{signal_class}}++ for @plan;
print  "  reparto signal_class del plan : ".join(", ",map {"$_=$bs{$_}"} sort keys %bs)."\n";

# Primarias que se asignarian, visible YA EN DRY-RUN: es el unico numero que
# cambia con la regla nueva (una primaria por rol+dispositivo en vez de por rol),
# y este es el unico paso del proyecto que reescribe datos de produccion.
{
  my ($ph,$pr,%devs)=(0,0);
  for my $k (keys %attr){
    next unless $attr{$k}{is_primary};
    my ($iid)=split /\|/,$k;
    my ($p)=grep { $_->{instance_id}==$iid } @plan;
    next unless $p;
    $devs{ $p->{role_id}.'|'.($p->{iddev}//0) }=1;
    $p->{signal_class} eq 'health_sli' ? $ph++ : $pr++;
  }
  printf "  primarias que se asignarian   : %d (salud=%d, riesgo=%d)\n", $ph+$pr, $ph, $pr;
  printf "  -> parejas rol+dispositivo    : %d\n", scalar keys %devs;
  print  "     (con la regla ANTIGUA eran 495 en total; el aumento es lo esperado)\n";
}
if ($o{v} && @sin_rol){
  print "\n  (muestra SIN rol: instance_id | subtype | type):\n";
  printf "    %-10s %-24s %s\n",@$_ for @sin_rol[0..9];
}
if (@rol_inexistente){
  print "\n  ! roles resueltos que NO existen/activos (revisar mapa/col7):\n";
  printf "    inst %-10s rol=%s\n",@$_ for @rol_inexistente[0..9];
}

# ---------------------------------------------------------------------------
# 6. commit (upsert; preserva human_confirmed; idempotente)
# ---------------------------------------------------------------------------
if ($DRY){ print "\nDRY-RUN: nada escrito. Revisa el plan y reejecuta con --commit.\n"; $dbh->rollback; $dbh->disconnect; exit 0; }

eval {
  my $ins=$dbh->prepare(
    "INSERT INTO sem_binding_role
        (instance_id,role_id,relation_type,is_primary,weight,signal_class_override,confidence,source)
     VALUES (?,?,?,?,?,NULL,'inherited','rules')
     ON DUPLICATE KEY UPDATE
        is_primary=VALUES(is_primary), weight=VALUES(weight),
        relation_type=VALUES(relation_type), source='rules'");
  my ($nins,$nupd,$nskip)=(0,0,0);
  for my $p (@plan){
    my $key="$p->{instance_id}|$p->{role_id}";
    # preservar lo humano: no pisar bindings human_confirmed
    if ($existing{$key} && $existing{$key}{confidence} eq 'human_confirmed'){ $nskip++; next; }
    my $a=$attr{$key}||{is_primary=>0,weight=>0.0};
    my $was=exists $existing{$key};
    $ins->execute($p->{instance_id},$p->{role_id},$p->{via},$a->{is_primary},$a->{weight});
    $was ? $nupd++ : $nins++;
  }
  $dbh->commit;
  printf "\nCOMMIT OK. bindings de rol: nuevos=%d, actualizados=%d, preservados(human)=%d\n",
         $nins,$nupd,$nskip;
  print "Recuerda: no borra bindings obsoletos (eso es cnm_reconcile.pl).\n";
  1;
} or do { my $e=$@||'err'; $dbh->rollback; die "\nERROR (rollback, nada escrito): $e\n"; };
$dbh->disconnect;
