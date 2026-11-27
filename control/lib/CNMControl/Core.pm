#####################################################################################################
# File: (CNMControl::Core.pm)
# Description:
#	Core of cnm-control: registry of object kinds, validation of the desired state, plan
#	(desired state versus current state) and apply.
#
#	Each kind of CNM object is a module CNMControl::Kind::<Name> with this interface
#	(package methods, called as Kind->method):
#
#	  order()                     number: kinds are read and applied in ascending order
#	  validate($r)                -> ($normalized_r, $error)              pure
#	  key($r)                     -> text that identifies the object       pure
#	  label($r)     (optional)    -> the object as the user wrote it, when key() normalizes it
#	  merge($a,$b)  (optional)    -> ($merged, $error): same key, different content  pure
#	  read($ctx, \@resources)     -> \%current (by key)                    reads the database
#	  diff($r, $current, $ctx)    -> (\@actions, \@errors, \@warnings)     pure
#	  apply($ctx, \@actions)      -> \@errors                              writes
#
#	An action is { kind, op, ref, text, ...kind-specific data }.
#	Adding a kind = one module + one line in %KINDS.
#	This module does not touch the database itself: read() and apply() of each kind do,
#	through $ctx->{dbh}, which the tests simulate.
#	Design: cnm-docs, PROY-CNM-cnm-control-Diseno §3 and §5.
# Set Tab=3
#####################################################################################################
package CNMControl::Core;
$VERSION='0.40';
use strict;
use JSON;
use CNMControl::Kind::View;
use CNMControl::Kind::Device;
use CNMControl::Kind::Metric;
require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(kinds validate_state make_plan apply_plan plan_text summary blocked);

# Name of the kind in the state file ("kind") => module
my %KINDS = (
	'view'   => 'CNMControl::Kind::View',
	'device' => 'CNMControl::Kind::Device',
	'metric' => 'CNMControl::Kind::Metric',
);
my %STATE_KEYS = map { $_=>1 } qw(version descr cid resources);

sub kinds { return sort { $KINDS{$a}->order() <=> $KINDS{$b}->order() } keys %KINDS; }

#----------------------------------------------------------------------------
# validate_state($data) -> (\%by_kind, \@errors, \@derived)
# $data: { version:1, resources:[...] }. Validates every resource with its kind and merges
# repeated ones (same kind and key): identical => one; different => error.
# derived: errors of a resource that comes from the same place (the same inventory line) as
# a resource of an earlier kind that already failed, e.g. the metrics of a device with an
# invalid name. They block like the others; they are shown apart, as in the plan.
#----------------------------------------------------------------------------
sub validate_state {
my ($data)=@_;
my @err=();
	return ({}, ['el estado no es un objeto JSON']) if (ref($data) ne 'HASH');
	foreach my $k (keys %$data) { push @err, "estado: clave desconocida '$k'" if (! $STATE_KEYS{$k}); }
	push @err, 'estado: falta "version": 1' if ((! defined $data->{version}) || ($data->{version} ne '1'));
	push @err, 'estado: "resources" tiene que ser una lista' if (ref($data->{resources}) ne 'ARRAY');
	return ({}, \@err, []) if (@err);

	my %by_kind=(); my %seen=(); my @der=(); my %failed=();	# origin => lowest order of a failed kind
	my $json = JSON->new->canonical(1);
	my $i=0;
	foreach my $r (@{$data->{resources}}) {
		$i++;
		my $where = (ref($r) eq 'HASH' && $r->{_origin}) ? $r->{_origin} : "recurso $i";
		if ((ref($r) ne 'HASH') || (! defined $r->{kind})) { push @err, "$where: sin \"kind\""; next; }
		my $kind = $KINDS{$r->{kind}};
		if (! $kind) { push @err, "$where: kind desconocido '$r->{kind}' (validos: ".join(', ',kinds()).")"; next; }
		my %copy = %$r; delete $copy{_origin};
		my ($n,$e) = $kind->validate(\%copy);
		if ($e) {
			my $o = $kind->order();
			if (defined $failed{$where} && ($failed{$where} < $o)) { push @der, "$where ($r->{kind}): $e"; }
			else { push @err, "$where ($r->{kind}): $e"; }
			$failed{$where} = $o if ((! defined $failed{$where}) || ($o < $failed{$where}));
			next;
		}
		my $k = $kind->key($n);
		my $sig = $json->encode($n);
		if (my $s = $seen{$r->{kind}}{$k}) {
			next if ($s->{sig} eq $sig);
			# Different content: the kind may know how to merge them (a view referenced by one
			# profile and defined by another, for instance); otherwise it is an error
			my $old = $by_kind{$r->{kind}}[$s->{idx}];
			my %a = %$old; delete $a{_origin};
			if (! $kind->can('merge')) { push @err, "$where: $r->{kind} '$k' repetido con valores distintos (primero en $s->{where})"; next; }
			my ($m,$me) = $kind->merge(\%a, $n);
			if ($me) { push @err, "$where: $r->{kind} '$k' repetido con valores distintos: $me (primero en $s->{where})"; next; }
			$m->{_origin} = $old->{_origin};
			$by_kind{$r->{kind}}[$s->{idx}] = $m;
			$s->{sig} = $json->encode({ map { $_=>$m->{$_} } grep { $_ ne '_origin' } keys %$m });
			next;
		}
		$n->{_origin}=$where;
		push @{$by_kind{$r->{kind}}}, $n;
		$seen{$r->{kind}}{$k} = { sig=>$sig, where=>$where, idx=>$#{$by_kind{$r->{kind}}} };
	}
	return (\%by_kind, \@err, \@der);
}

#----------------------------------------------------------------------------
# make_plan($ctx, \%by_kind) -> \%plan
#  plan = { actions=>[...], errors=>[...], derived=>[...], warnings=>[...], unchanged=>N }
#  errors: the causes; derived: errors that only repeat the failure of another resource of the
#  state (a kind's diff returns them as { derived=>1, text=>... }). Both block apply_plan.
#----------------------------------------------------------------------------
sub make_plan {
my ($ctx,$by_kind)=@_;
my %plan=(actions=>[], errors=>[], derived=>[], warnings=>[], unchanged=>0);
	foreach my $name (kinds()) {
		my $rs = $by_kind->{$name} or next;
		my $kind = $KINDS{$name};
		my $current = $kind->read($ctx, $rs);
		foreach my $r (@$rs) {
			my $k = $kind->key($r);
			my ($acc,$err,$warn) = $kind->diff($r, $current->{$k}, $ctx);
			$k = $kind->label($r) if ($kind->can('label'));		# what the user wrote, for the messages
			foreach my $e (@$err) {
				if (ref($e) eq 'HASH') { push @{$plan{derived}}, "$r->{_origin} ($name $k): $e->{text}"; }
				else { push @{$plan{errors}}, "$r->{_origin} ($name $k): $e"; }
			}
			push @{$plan{warnings}}, map { "$name $k: $_" } @$warn;
			push @{$plan{actions}}, @$acc;
			$plan{unchanged}++ if ((! @$acc) && (! @$err));
		}
	}
	return \%plan;
}

#----------------------------------------------------------------------------
# apply_plan($ctx, \%plan) -> \@errors
# Kind by kind, in order. If a kind fails, the next ones are not applied: they depend on it.
#----------------------------------------------------------------------------
sub apply_plan {
my ($ctx,$plan)=@_;
	foreach my $name (kinds()) {
		my @acc = grep { $_->{kind} eq $name } @{$plan->{actions}};
		next if (! @acc);
		my $err = $KINDS{$name}->apply($ctx, \@acc);
		return [ map { "$name: $_" } @$err ] if (@$err);
	}
	return [];
}

sub summary {
my ($plan)=@_;
	my %n=(); $n{"$_->{kind}.$_->{op}"}++ foreach (@{$plan->{actions}});
	return { actions=>scalar(@{$plan->{actions}}), errors=>scalar(@{$plan->{errors}}),
				derived=>scalar(@{$plan->{derived}||[]}), warnings=>scalar(@{$plan->{warnings}}),
				unchanged=>$plan->{unchanged}, by_type=>\%n };
}

sub blocked { my $p=shift; return (@{$p->{errors}} || @{$p->{derived}||[]}) ? 1 : 0; }

#----------------------------------------------------------------------------
# plan_text($plan, $verbose) -> text
# With errors, the text starts saying that nothing can be applied, shows the causes, groups
# the derived errors (listed with $verbose) and shows the actions as blocked.
#----------------------------------------------------------------------------
sub plan_text {
my ($plan,$verbose)=@_;
my @l=();
	my $s=summary($plan);
	if (blocked($plan)) {
		push @l, sprintf("  NO SE PUEDE APLICAR: %d %s%s", $s->{errors}, ($s->{errors}==1 ? 'error' : 'errores'),
			($s->{derived} ? " (y $s->{derived} derivados de ".($s->{errors}==1 ? 'el' : 'ellos').")" : ''));
		push @l, map { "  ERROR  $_" } @{$plan->{errors}};
		if ($s->{derived}) {
			if ($verbose) { push @l, map { "  ERROR  (derivado) $_" } @{$plan->{derived}}; }
			else { push @l, "  ($s->{derived} errores mas, derivados de los anteriores; --verbose para verlos)"; }
		}
		if (@{$plan->{actions}}) {
			push @l, "  Acciones bloqueadas (no se aplica ninguna mientras haya errores):";
			push @l, map { sprintf("  %-12s %-12s %s", $_->{kind}, $_->{op}, $_->{text}) } @{$plan->{actions}};
		}
	}
	else {
		push @l, map { sprintf("  %-12s %-12s %s", $_->{kind}, $_->{op}, $_->{text}) } @{$plan->{actions}};
		push @l, "  (sin cambios)" if (! @{$plan->{actions}});
		# Modifications counted by attribute: a mass change is seen at a glance
		my %n=();
		foreach my $x (grep { $_->{op} eq 'update' } @{$plan->{actions}}) {
			$n{"$x->{kind}.$_"}++ foreach (keys %{$x->{changes}||{}});
			$n{"$x->{kind}.$x->{fchanges}{$_}[2]"}++ foreach (keys %{$x->{fchanges}||{}});
		}
		push @l, "  MODIFICA: ".join(', ', map { "$_ en $n{$_}" } sort keys %n) if (%n);
	}
	push @l, map { "  AVISO  $_" } @{$plan->{warnings}};
	push @l, sprintf("RESUMEN %d acciones, %d sin cambios, %d avisos, %d errores%s",
		$s->{actions}, $s->{unchanged}, $s->{warnings}, $s->{errors}, ($s->{derived} ? " (+$s->{derived} derivados)" : ''));
	return join("\n",@l)."\n";
}

1;
