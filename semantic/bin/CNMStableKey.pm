package CNMStableKey;
# =============================================================================
# CNMStableKey — derivación de la identidad estable (stable_key) de una métrica.
#
# Lógica ÚNICA compartida por cnm_stable_key_diag.pl (diagnóstico) y
# cnm_mirror.pl (escritura). Las REGLAS son externas (stable_key_rules.conf):
# añadir un subtype nuevo no requiere tocar código.
#
# Uso:
#   use CNMStableKey;
#   my $sk = CNMStableKey->new(rules_file => '/opt/data/semantic/stable_key_rules.conf');
#   my ($via, $stable_key) = $sk->derive($subtype, $iid, $label);
#
# $via ∈ (ALL | iid_stable | parsed_label | iid_weak | iid_fallback)
#   ALL/iid_stable/parsed_label = identidad ROBUSTA
#   iid_weak                    = identidad DÉBIL declarada (iid/label no fiables)
#   iid_fallback                = no se supo derivar (falta regla para ese subtype)
# =============================================================================
use strict;
use warnings;

# Longitud máxima indexable del stable_key (MariaDB 10.0: 767 bytes; stable_key
# indexado a 125 chars). Truncamos a 240 (columna) pero avisamos si supera 125.
use constant MAX_STABLE_KEY => 240;
use constant IDX_STABLE_KEY => 125;

sub new {
    my ($class, %arg) = @_;
    my $self = bless { rules => [], warnings => [] }, $class;
    $self->_load_rules($arg{rules_file}) if $arg{rules_file};
    return $self;
}

# --- localizar el fichero de reglas por rutas candidatas ---------------------
sub find_rules_file {
    my ($explicit) = @_;
    my @cand = ($explicit,
                './stable_key_rules.conf',
                '/opt/data/semantic/stable_key_rules.conf',
                './semantic/stable_key_rules.conf.example',
                './stable_key_rules.conf.example');
    for (@cand) { return $_ if $_ && -r $_; }
    return undef;
}

# --- cargar y compilar las reglas del fichero --------------------------------
sub _load_rules {
    my ($self, $file) = @_;
    open(my $fh, '<', $file) or die "CNMStableKey: no puedo leer $file: $!\n";
    my $ln = 0;
    while (my $line = <$fh>) {
        $ln++; $line =~ s/\r?\n$//;
        next if $line =~ /^\s*#/ || $line =~ /^\s*$/;
        my ($class, $sel, $pat) = split /\|/, $line, 3;
        $pat = '' unless defined $pat;
        for ($class, $sel) { s/^\s+|\s+$//g if defined }
        die "CNMStableKey: clase inválida '$class' (línea $ln de $file)\n"
            unless defined $class && $class =~ /^(iid_all|iid_direct|label_prefix|iid_weak)$/;
        my %r = (class => $class, line => $ln);
        if    ($sel eq '*')                { $r{sel} = 'any'; }
        elsif ($sel =~ /^subtype=(.+)/)    { $r{sel} = 'subtype';    $r{val} = $1; }
        elsif ($sel =~ /^subtype_re=(.+)/) { $r{sel} = 'subtype_re'; $r{re}  = qr/$1/; }
        elsif ($sel =~ /^iid_in=(.+)/)     { $r{sel} = 'iid_in';     $r{val} = { map { $_ => 1 } split /,/, $1 }; }
        else { die "CNMStableKey: selector inválido '$sel' (línea $ln)\n"; }
        if ($class eq 'label_prefix') {
            die "CNMStableKey: label_prefix sin patrón (línea $ln)\n" unless length $pat;
            $r{prefix} = qr/$pat/i;
        }
        push @{$self->{rules}}, \%r;
    }
    close($fh);
    $self->{rules_file} = $file;
    return scalar @{$self->{rules}};
}

sub n_rules   { scalar @{$_[0]->{rules}} }
sub rules_file { $_[0]->{rules_file} }

# --- quitar ' (hostname)' final, con paréntesis anidados balanceados ---------
sub _strip_host {
    my ($s) = @_;
    if ($s =~ /\s*\(.*\)\s*$/) {
        my $d = 0; my $start = -1;
        for (my $i = length($s) - 1; $i >= 0; $i--) {
            my $c = substr($s, $i, 1);
            $d++ if $c eq ')'; $d-- if $c eq '(';
            if ($d == 0 && $c eq '(') { $start = $i; last; }
        }
        $s = substr($s, 0, $start) if $start > 0;
    }
    $s =~ s/\s+$//;
    return $s;
}

sub _sel_match {
    my ($r, $subtype, $iid) = @_;
    return 1                               if $r->{sel} eq 'any';
    return ($subtype eq $r->{val} ? 1 : 0) if $r->{sel} eq 'subtype';
    return ($subtype =~ $r->{re} ? 1 : 0)  if $r->{sel} eq 'subtype_re';
    return ($r->{val}{$iid} ? 1 : 0)       if $r->{sel} eq 'iid_in';
    return 0;
}

# --- derivar (via, stable_key) para una métrica ------------------------------
sub derive {
    my ($self, $subtype, $iid, $label) = @_;
    $iid = defined $iid ? $iid : 'ALL';
    for my $r (@{$self->{rules}}) {
        next unless _sel_match($r, $subtype, $iid);
        my $c = $r->{class};
        return ('ALL', 'ALL')       if $c eq 'iid_all';
        return ('iid_stable', $iid) if $c eq 'iid_direct';
        return ('iid_weak', $iid)   if $c eq 'iid_weak';
        if ($c eq 'label_prefix') {
            if (defined $label && $label =~ $r->{prefix}) {
                my $rest = _strip_host($');   # $' = lo que sigue al prefijo
                $rest =~ s/^\s+|\s+$//g;
                return ('parsed_label', _clip($rest)) if length $rest;
            }
            # la regla aplicaba por subtype pero el label no casó: seguir probando
        }
    }
    return ('iid_fallback', $iid);
}

# --- recortar stable_key a la longitud de columna (avisa si supera índice) ---
sub _clip {
    my ($s) = @_;
    if (length($s) > MAX_STABLE_KEY) { $s = substr($s, 0, MAX_STABLE_KEY); }
    return $s;
}

# ¿el via es identidad robusta?
sub is_robust {
    my ($self, $via) = @_;
    return ($via eq 'ALL' || $via eq 'iid_stable' || $via eq 'parsed_label') ? 1 : 0;
}

1;
