#!/usr/bin/perl -w
#------------------------------------------------------------------------------
# Prueba de ProvisionLite::ProvGuard (REG-CNM-Deuda 4.104, PROY-CNM-Alertas-Azules §6).
# Cada caso dice que haria la salvaguarda y que hace la provision de hoy. Los casos
# que la salvaguarda protege tienen que FALLAR con el comportamiento de hoy
# (quitar de la plantilla todo lo que falta en una sola lectura).
#
#   perl t/PROV_prov_guard.t            (desde /opt/crawler/bin, o con -I)
#------------------------------------------------------------------------------
use lib "/opt/crawler/bin";
use FindBin; use lib "$FindBin::Bin/..";
use strict;
use Test::More;
use ProvisionLite::ProvGuard qw(guard_mode valid_iids guard_decide GUARD_OFF GUARD_ON GUARD_WATCH);

sub m_ { my %h=map { $_ => { label=>"L$_" } } @_; return \%h; }

# Lo que se quita hoy: lo que falta en la primera lectura (o todo, si no hay datos)
sub today_gone {
my ($tpl,$read)=@_;
	return [ sort grep { (ref($read) ne 'HASH') || (! exists $read->{$_}) } @$tpl ];
}

#--- guard_mode -------------------------------------------------------------
is(guard_mode(undef), GUARD_ON, 'modo: sin fichero, 1 (el estado soportado)');
is(guard_mode("A = 1\n"), GUARD_ON, 'modo: sin la linea, 1 (el estado soportado)');
is(guard_mode("PROV_GUARD = 0\n"), GUARD_OFF, 'modo: 0 solo si se escribe');
is(guard_mode("# PROV_GUARD = 0\n"), GUARD_ON, 'modo: un 0 comentado no cuenta, 1');
is(guard_mode("PROV_GUARD = 1\n"), GUARD_ON, 'modo: 1');
is(guard_mode("PROV_GUARD=2\n"), GUARD_WATCH, 'modo: 2, sin espacios');
is(guard_mode("#PROV_GUARD = 2\n"), GUARD_ON, 'modo: comentada no cuenta, 1');
is(guard_mode("PROV_GUARD = 7\n"), GUARD_ON, 'modo: valor no valido, 1');
is(guard_mode("PROV_GUARD =\n"), GUARD_ON, 'modo: linea sin valor, 1');
is(guard_mode("PROV_GUARD = 1\nPROV_GUARD = 0\n"), GUARD_OFF, 'modo: manda la ultima linea');

#--- valid_iids -------------------------------------------------------------
is(scalar(valid_iids(undef)), 0, 'validas: undef');
is(scalar(valid_iids({})), 0, 'validas: vacia');
is(scalar(valid_iids({ U=>{} })), 0, 'validas: solo U');
is(scalar(valid_iids(m_(1,2))), 2, 'validas: dos');

#--- guard_decide -----------------------------------------------------------
my @CASES = (
 { name=>'completa: no cambia nada', tpl=>[1,2,3], read=>m_(1,2,3), second=>undef,
   skip=>0, gone=>[], reappeared=>[], reread=>0, today_differs=>0 },
 { name=>'G1 vacia (el caso VMware): no se toca', tpl=>[1,2,3], read=>{}, second=>undef,
   skip=>1, gone=>[], reappeared=>[], reread=>0, today_differs=>1 },
 { name=>'G1 sin datos (undef, clase 1 y 3): no se toca', tpl=>[1,2], read=>undef, second=>undef,
   skip=>1, gone=>[], reappeared=>[], reread=>0, today_differs=>1 },
 { name=>"G1 solo 'U' (error en core_snmp_table): no se toca", tpl=>[1,2], read=>{ U=>{} }, second=>undef,
   skip=>1, gone=>[], reappeared=>[], reread=>0, today_differs=>1 },
 { name=>'G1 vacia y forzada: desaparece todo, como hoy', tpl=>[1,2], read=>{}, force=>1, second=>undef,
   skip=>0, gone=>[1,2], reappeared=>[], reread=>0, today_differs=>0 },
 { name=>'G2 corte pasajero: reaparecen en la segunda lectura', tpl=>[1,2,3,4], read=>m_(1,2), second=>m_(1,2,3,4),
   skip=>0, gone=>[], reappeared=>[3,4], reread=>1, today_differs=>1 },
 { name=>'G2 baja legitima: falta en las dos lecturas', tpl=>[1,2,3], read=>m_(1,2), second=>m_(1,2),
   skip=>0, gone=>[3], reappeared=>[], reread=>1, today_differs=>0 },
 { name=>'G2 mixto: una reaparece, otra se va', tpl=>[1,2,3], read=>m_(1), second=>m_(1,2),
   skip=>0, gone=>[3], reappeared=>[2], reread=>1, today_differs=>1 },
 { name=>'G2 corte que se repite igual: desaparecen (limite aceptado)', tpl=>[1,2,3,4], read=>m_(1,2), second=>m_(1,2),
   skip=>0, gone=>[3,4], reappeared=>[], reread=>1, today_differs=>0 },
 { name=>'G2 segunda lectura vacia: no se toca', tpl=>[1,2,3], read=>m_(1), second=>{},
   skip=>1, gone=>[], reappeared=>[], reread=>1, today_differs=>1 },
 { name=>'G2 forzada sigue haciendo la segunda lectura', tpl=>[1,2,3], read=>m_(1,2), force=>1, second=>m_(1,2,3),
   skip=>0, gone=>[], reappeared=>[3], reread=>1, today_differs=>1 },
 { name=>'plantilla vacia: nada que proteger', tpl=>[], read=>{}, second=>undef,
   skip=>0, gone=>[], reappeared=>[], reread=>0, today_differs=>0 },
 { name=>'instancia nueva sin bajas: sin segunda lectura', tpl=>[1], read=>m_(1,2), second=>undef,
   skip=>0, gone=>[], reappeared=>[], reread=>0, today_differs=>0 },
);

foreach my $c (@CASES) {
	my $called=0;
	my $r = guard_decide({ tpl=>$c->{tpl}, read=>$c->{read}, force=>$c->{force},
		reread => sub { $called++; return $c->{second}; } });
	is($r->{skip}, $c->{skip}, "$c->{name}: skip");
	is_deeply($r->{gone}, $c->{gone}, "$c->{name}: desaparecen");
	is_deeply($r->{reappeared}, $c->{reappeared}, "$c->{name}: reaparecen");
	is($called, $c->{reread}, "$c->{name}: segunda lectura");
	is($r->{reread}, $c->{reread}, "$c->{name}: marca de segunda lectura");
	foreach my $iid (@{$c->{reappeared}}) {
		ok(exists $r->{second}{$iid}, "$c->{name}: trae la entrada de la segunda lectura de $iid");
	}

	# Lo que se quitaria con la salvaguarda frente a lo que se quita hoy
	my $guard_gone = $r->{skip} ? [] : $r->{gone};
	my $differs = (join(',',@$guard_gone) ne join(',',@{today_gone($c->{tpl},$c->{read})})) ? 1 : 0;
	is($differs, $c->{today_differs}, "$c->{name}: ".($c->{today_differs} ? 'hoy se pierde algo que la salvaguarda protege' : 'igual que hoy'));
}

done_testing();
